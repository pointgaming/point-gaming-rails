class Bet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include StreamsHelper

  before_validation :populate_bettor_amount, :on => :create

  scope :for_user, lambda {|user| any_of({bettor_id: user._id}, {bookie_id: user._id}) }
  scope :for_bookie, lambda {|user| where(bookie_id: user._id) }
  scope :for_bettor, lambda {|user| where(bettor_id: user._id) }
  scope :available_for_user, lambda {|user| any_of({:bettor_id.in => [user._id, nil]}, {bookie_id: user._id}) }
  scope :for_match, lambda {|match| where(match_id: match._id) }
  scope :pending, where(outcome: :undetermined)

  attr_accessible :bookie_amount, :bettor_odds, :map

  after_create :publish_bet_created
  after_update :publish_bet_updated
  after_destroy :publish_bet_destroyed

  # store winner/loser names historically
  field :winner_name, :type => String
  field :loser_name, :type => String

  field :map, :type => String
  field :bookie_amount, :type => Integer
  field :bettor_amount, :type => Integer
  field :bookie_odds, :type => Integer, default: 1
  field :bettor_odds, :type => Integer
  field :match_hash, :type => String

  # values: undetermined, cancelled, bookie_won, bettor_won, void
  field :outcome, :type => String, default: :undetermined

  belongs_to :match

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :winner, :polymorphic => true

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :loser, :polymorphic => true

  # user who owns/offered the bet
  belongs_to :bookie, class_name: 'User'

  # user who accepted the bet
  belongs_to :bettor, class_name: 'User'

  validates :match_hash, :presence=>true
  validates :winner, :presence=>true
  validates :loser, :presence=>true
  validates :map, :presence=>true
  validates :bookie_amount, :presence=>true, :numericality => true
  validates :bettor_amount, :presence=>true, :numericality => true
  validates :bookie_odds, :presence=>true
  validates :bettor_odds, :presence=>true
  validate :check_winner_and_loser
  validate :check_match_state, on: :create
  validate :check_bookie_points, on: :create
  validate :check_match_hash, on: :create
  validate :check_bettor_points, on: :update

  def odds_options
    [['1:1','1'], ['1:2','2'], ['1:3','3'], ['1:4','4'], ['1:5','5'], 
     ['1:6','6'], ['1:7','7'], ['1:8','8'], ['1:9','9'], ['1:10','10']]
  end

  def participants(user)
    (user._id === bookie_id) ? 
      "#{winner.try(:display_name)} vs #{loser.try(:display_name)}" : 
      "#{loser.try(:display_name)} vs #{winner.try(:display_name)}"
  end

  def against_user(user)
    (user._id === bookie_id) ? bettor : bookie
  end

  def bet_amount(user)
    if user._id === bookie_id
      bookie_amount
    elsif user._id === bettor_id
      bettor_amount
    else
      nil
    end
  end

  def display_odds
    "#{self.bookie_odds}:#{self.bettor_odds}"
  end

  def risk_amount(user)
    if user._id === bookie_id
      bookie_amount
    else
      bettor_amount
    end
  end

  def win_amount(user)
    if user._id === bookie_id
      bettor_amount
    else
      bookie_amount
    end
  end

  def outcome_amount(user)
    if self.outcome === 'bettor_won'
      user._id === bettor_id ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    elsif self.outcome === 'bookie_won'
      user._id === bookie_id ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    else
      nil
    end
  end

private

  def populate_bettor_amount
    return unless self.bookie_amount.is_a?(Fixnum) && self.bettor_odds.is_a?(Fixnum)
    self.bettor_amount = self.bookie_amount * self.bettor_odds
  end

  def check_match_state
    errors.add(:match, "is not currently accepting new bets.") unless match.state === 'new'
  end

  def check_match_hash
    errors.add(:match, " details have changed. This bet was not accepted.") if self.match_hash != self.match.match_hash
  end

  def check_bookie_points
    pending_points = Bet.pending.for_bookie(bookie).sum(:bookie_amount).to_i
    pending_points += Bet.pending.for_bettor(bookie).sum(:bettor_amount).to_i

    errors.add(:bookie_amount, "cannot be larger than your available points.") if bookie_amount > (bookie.points - pending_points)
  end

  def check_bettor_points
    return unless bettor_id_changed?

    pending_points = Bet.pending.for_bookie(bettor).sum(:bookie_amount).to_i
    pending_points += Bet.pending.for_bettor(bettor).sum(:bettor_amount).to_i

    errors.add(:bettor_amount, "cannot be larger than your available points.") if bettor_amount > (bettor.points - pending_points)
  end

  def check_winner_and_loser
    errors.add(:loser, "cannot be the same as winner") if winner === loser
  end

  def can_publish_message?
    self.match.present? && self.match.room.present?
  end

  def publish_bet_created
    return unless can_publish_message?

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.new',
      :data => {
        :bet => self.as_json(:include => [:bookie]),
        :bet_path => polymorphic_path([match, self])
      }
    }.to_json)
  end

  def publish_bet_updated
    return unless can_publish_message?

    action = (bettor_id_changed? && bettor) ? 'Bet.Bettor.new' : 'Bet.update'

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => action,
      :data => {
        :bet => self.as_json(:include => [:bookie, :bettor])
      }
    }.to_json)
  end

  def publish_bet_destroyed()
    return unless can_publish_message?

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.destroy', 
      :data => {
        :bet => self.as_json(:include => [:bookie, :bettor])
      }
    }.to_json)
  end
end
