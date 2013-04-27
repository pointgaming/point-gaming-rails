class Bet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include StreamsHelper

  before_validation :populate_taker_wager, :on => :create
  before_validation :populate_taker_odds, :on => :create

  scope :for_user, lambda {|user| any_of({taker_id: user._id}, {offerer_id: user._id}) }
  scope :for_offerer, lambda {|user| where(offerer_id: user._id) }
  scope :for_taker, lambda {|user| where(taker_id: user._id) }
  scope :available_for_user, lambda {|user| any_of({:taker_id.in => [user._id, nil]}, {offerer_id: user._id}) }
  scope :for_match, lambda {|match| where(match_id: match._id) }
  scope :pending, where(outcome: :undetermined)
  scope :unaccepted, where(taker_id: nil)

  attr_accessible :offerer_wager, :offerer_odds, :match_hash

  after_create :publish_bet_created
  after_update :publish_bet_updated
  after_destroy :publish_bet_destroyed

  # store offerer_choice/taker_choice names historically
  field :offerer_choice_name, :type => String
  field :taker_choice_name, :type => String

  field :offerer_wager, :type => Integer
  field :taker_wager, :type => Integer
  field :offerer_odds, :type => String, default: '1:1'
  field :taker_odds, :type => String, default: '1:1'
  field :match_hash, :type => String

  # values: undetermined, cancelled, offerer_won, taker_won, void
  field :outcome, :type => String, default: :undetermined

  belongs_to :match

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :offerer_choice, :polymorphic => true

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :taker_choice, :polymorphic => true

  # user who owns/offered the bet
  belongs_to :offerer, class_name: 'User'
  delegate :username, :to => :offerer, :prefix => true, :allow_nil => true

  # user who accepted the bet
  belongs_to :taker, class_name: 'User'
  delegate :username, :to => :taker, :prefix => true, :allow_nil => true

  validates :match_hash, :presence=>true
  validates :offerer_choice, :presence=>true
  validates :taker_choice, :presence=>true
  validates :offerer_wager, :presence=>true, :numericality => true
  validates :taker_wager, :presence=>true, :numericality => true
  validates :offerer_odds, :presence=>true
  validates :taker_odds, :presence=>true
  validate :check_offerer_choice_and_taker_choice
  validate :check_match_state, on: :create
  validate :check_offerer_points, on: :create
  validate :check_match_hash, on: :create
  validate :check_taker_points, on: :update

  def odds_options
    ['10:1', '9:1', '8:1', '7:1', '6:1', '5:1', '4:1', '3:1', '2:1', '1:1',
     '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '1:8', '1:9', '1:10']
  end

  def participants(user)
    (user._id === offerer_id) ? 
      "#{offerer_choice.try(:display_name)} vs #{taker_choice.try(:display_name)}" : 
      "#{taker_choice.try(:display_name)} vs #{offerer_choice.try(:display_name)}"
  end

  def against_user(user)
    (user._id === offerer_id) ? taker : offerer
  end

  def bet_amount(user)
    if user._id === offerer_id
      offerer_wager
    elsif user._id === taker_id
      taker_wager
    else
      nil
    end
  end

  def display_odds(user)
    if user._id === offerer_id
      self.offerer_odds
    else
      self.taker_odds
    end
  end

  def risk_amount(user)
    if user._id === offerer_id
      offerer_wager
    else
      taker_wager
    end
  end

  def win_amount(user)
    if user._id === offerer_id
      taker_wager
    else
      offerer_wager
    end
  end

  def outcome_amount(user)
    if self.outcome === 'taker_won'
      user._id === taker_id ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    elsif self.outcome === 'offerer_won'
      user._id === offerer_id ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    else
      nil
    end
  end

  def as_json(options={})
    super({
      methods: [:offerer_username, :taker_username]
    }.merge(options))
  end

private

  def populate_taker_wager
    return unless self.offerer_wager.is_a?(Fixnum) && self.offerer_odds.present?
    pieces = self.offerer_odds.split(":").map(&:to_i)

    if pieces.first === 0
      # this shouldn't happen, but it will prevent division by 0
      self.taker_wager = 0
    else
      self.taker_wager = ((self.offerer_wager * pieces.last) / pieces.first).to_i
    end
  end

  def populate_taker_odds
    return unless self.offerer_odds
    pieces = self.offerer_odds.split(":")
    self.taker_odds = "#{pieces.last}:#{pieces.first}"
  end

  def check_match_state
    errors.add(:match, "is not currently accepting new bets.") unless match.state === 'new'
  end

  def check_match_hash
    errors.add(:match, " details have changed. This bet was not accepted.") if self.match_hash != self.match.match_hash
  end

  def check_offerer_points
    pending_points = Bet.pending.for_offerer(offerer).sum(:offerer_wager).to_i
    pending_points += Bet.pending.for_taker(offerer).sum(:taker_wager).to_i

    errors.add(:offerer_wager, "cannot be larger than your available points.") if offerer_wager > (offerer.points - pending_points)
  end

  def check_taker_points
    return unless taker_id_changed?

    pending_points = Bet.pending.for_offerer(taker).sum(:offerer_wager).to_i
    pending_points += Bet.pending.for_taker(taker).sum(:taker_wager).to_i

    errors.add(:taker_wager, "cannot be larger than your available points.") if taker_wager > (taker.points - pending_points)
  end

  def check_offerer_choice_and_taker_choice
    errors.add(:taker_choice, "cannot be the same as offerer_choice") if offerer_choice === taker_choice
  end

  def can_publish_message?
    self.match.present? && self.match.room.present?
  end

  def publish_bet_created
    return unless can_publish_message?

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.new',
      :data => {
        :bet => self.as_json(:include => [:offerer]),
        :bet_path => polymorphic_path([match, self])
      }
    }.to_json)
  end

  def publish_bet_updated
    return unless can_publish_message?

    action = (taker_id_changed? && taker) ? 'Bet.Taker.new' : 'Bet.update'

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => action,
      :data => {
        :bet => self.as_json(:include => [:offerer, :taker])
      }
    }.to_json)
  end

  def publish_bet_destroyed()
    return unless can_publish_message?

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.destroy', 
      :data => {
        :bet => self.as_json(:include => [:offerer, :taker])
      }
    }.to_json)
  end
end
