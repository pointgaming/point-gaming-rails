class Bet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  include Betting::BetPublication
  include Betting::PlayerBetting
  include Betting::TeamBetting

  before_validation :populate_taker_wager, :on => :create
  before_validation :populate_taker_odds, :on => :create

  scope :for_user, lambda {|user| any_of({taker_id: user._id}, {offerer_id: user._id}) }
  scope :for_offerer, lambda {|user| where(offerer_id: user._id) }
  scope :for_taker, lambda {|user| where(taker_id: user._id) }
  scope :available_for_user, lambda {|user| any_of({:taker_id.in => [user._id, nil]}, {offerer_id: user._id}) }
  scope :for_match, lambda {|match| where(match_id: match._id) }
  scope :pending, where(outcome: :undetermined)
  scope :accepted, where(outcome: :accepted)
  scope :accepted_and_finalized, lambda { self.in(outcome: [:taker_won, :offerer_won]) }
  scope :unaccepted, where(taker_id: nil)

  attr_accessible :offerer_wager, :offerer_odds, :match_hash

  # store offerer_choice/taker_choice names historically
  field :offerer_choice_name, :type => String
  field :taker_choice_name, :type => String

  field :offerer_wager, :type => Integer
  field :taker_wager, :type => Integer
  field :offerer_odds, :type => String, default: '1:1'
  field :taker_odds, :type => String, default: '1:1'
  field :match_hash, :type => String

  # values: undetermined, accepted, cancelled, offerer_won, taker_won, void
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
  validates :taker_choice, :presence=>true, :if => :requires_second_player?
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
    offerer?(user) ? 
      "#{offerer_choice.try(:display_name)} vs #{taker_choice.try(:display_name)}" : 
      "#{taker_choice.try(:display_name)} vs #{offerer_choice.try(:display_name)}"
  end

  def against_user(user)
    offerer?(user) ? taker : offerer
  end

  def bet_amount(user)
    if offerer?(user)
      offerer_wager
    elsif taker?(user)
      taker_wager
    else
      nil
    end
  end

  def display_odds(user)
    if offerer?(user)
      offerer_odds
    else
      taker_odds
    end
  end

  def risk_amount(user)
    if offerer?(user)
      offerer_wager
    else
      taker_wager
    end
  end

  def win_amount(user)
    if offerer?(user)
      taker_wager
    else
      offerer_wager
    end
  end

  def offerer?(user)
    user._id === offerer_id
  end

  def taker?(user)
    user._id === taker_id
  end

  def outcome_amount(user)
    if outcome === 'taker_won'
      taker?(user) ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    elsif outcome === 'offerer_won'
      offerer?(user) ? "+#{win_amount(user)}" : "-#{bet_amount(user)}"
    else
      nil
    end
  end

  def as_json(options={})
    super({
      methods: [:offerer_username, :taker_username],
      include: [:match, :betters]
    }.merge(options))
  end

  def accept!(user)
    accept(user)
    save && match.save ? true : false
  end

  def accept(user)
    if is_team_vs_mode?
      accept_team_bet(user)
    else
      accept_user_bet(user)
    end
  end

private

  def requires_second_player?
    match.requires_second_player?
  end

  def populate_taker_wager
    return unless offerer_wager.is_a?(Fixnum) && offerer_odds.present?
    pieces = offerer_odds.split(":").map(&:to_i)

    if pieces.first === 0
      # this shouldn't happen, but it will prevent division by 0
      self.taker_wager = 0
    else
      self.taker_wager = ((offerer_wager * pieces.last) / pieces.first).to_i
    end
  end

  def populate_taker_odds
    return unless offerer_odds
    pieces = offerer_odds.split(":")
    self.taker_odds = "#{pieces.last}:#{pieces.first}"
  end

  def check_match_state
    errors.add(:match, "is not currently accepting new bets.") unless match.state === 'new'
  end

  def check_match_hash
    errors.add(:match, "details have changed. This bet was not accepted.") if match_hash != match.match_hash
  end

  def check_offerer_points
    if is_team_vs_mode?
      check_offering_team_points
    else
      check_offering_user_points
    end
  end

  def check_taker_points
    return unless taker_id_changed? || taker_wager_changed?

    if is_team_vs_mode?
      check_taking_team_points
    else
      check_taking_user_points
    end
  end

  def check_offerer_choice_and_taker_choice
    if offerer_choice && offerer_choice === taker_choice 
      errors.add(:taker_choice, "cannot be the same as offerer_choice") 
    end
  end
end
