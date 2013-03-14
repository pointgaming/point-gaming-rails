class Bet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include StreamsHelper

  scope :for_user, lambda {|user| any_of({:bettor_id.in => [user._id, nil]}, {bookie_id: user._id}) }
  scope :for_match, lambda {|match| where(match_id: match._id) }
  scope :pending, where(outcome: :undetermined)

  attr_accessible :amount, :odds, :map

  after_create :publish_bet_created
  after_update :publish_bet_updated
  after_destroy :publish_bet_destroyed

  # store winner/loser names historically
  field :winner_name, :type => String
  field :loser_name, :type => String

  field :map, :type => String
  field :amount, :type => Integer
  field :odds, :type => String

  # values: undetermined, cancelled, bookie_won, bettor_won
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

  validates :winner, :presence=>true
  validates :loser, :presence=>true
  validates :map, :presence=>true
  validates :amount, :presence=>true, :numericality => true
  validates :odds, :presence=>true
  validate :check_winner_and_loser
  validate :check_match_state, on: :create
  validate :check_bookie_points, on: :create
  validate :check_bettor_points, on: :update

  def tooltip_attributes
    [:winner_name, :loser_name, :map, :amount, :odds, :your_risk_amount, :your_win_amount]
  end

  def odds_options
    ['1:1', '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '1:8', '1:9', '1:10']
  end

  def your_risk_amount
    "risk"
  end

  def your_win_amount
    "amount"
  end

  def participants(user)
    (user._id === bookie_id) ? 
      "#{winner.try(:playable_name)} vs #{loser.try(:playable_name)}" : 
      "#{loser.try(:playable_name)} vs #{winner.try(:playable_name)}"
  end

  def against_user(user)
    (user._id === bookie_id) ? bettor : bookie
  end

private

  def check_match_state
    errors.add(:match, "is not currently accepting new bets.") unless match.state === 'new'
  end

  def check_bookie_points
    pending_points = Bet.pending.for_user(bookie).sum(:amount).to_i

    errors.add(:amount, "cannot be larger than your available points.") if amount > (bookie.points - pending_points)
  end

  def check_bettor_points
    return unless bettor_id_changed?

    pending_points = Bet.pending.for_user(bettor).sum(:amount).to_i

    errors.add(:amount, "cannot be larger than your available points.") if amount > (bettor.points - pending_points)
  end

  def check_winner_and_loser
    errors.add(:loser, "cannot be the same as winner") if winner === loser
  end

  def publish_bet_created
    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.new',
      :data => {
        :bet => self.as_json(:include => [:bookie]),
        :bet_tooltip => bet_tooltip(self),
        :bet_path => polymorphic_path([match, self])
      }
    }.to_json)
  end

  def publish_bet_updated
    action = (bettor_id_changed? && bettor) ? 'Bet.Bettor.new' : 'Bet.update'

    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => action,
      :data => {
        :bet => self.as_json(:include => [:bookie, :bettor])
      }
    }.to_json)
  end

  def publish_bet_destroyed()
    BunnyClient.instance.publish_fanout("c.#{match.room.mq_exchange}", {
      :action => 'Bet.destroy', 
      :data => {
        :bet => self.as_json(:include => [:bookie, :bettor])
      }
    }.to_json)
  end
end
