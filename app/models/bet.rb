class Bet
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :amount, :odds, :map

  # store winner/loser names historically
  field :winner_name, :type => String
  field :loser_name, :type => String

  field :map, :type => String
  field :amount, :type => Integer
  field :odds, :type => String

  # values: undetermined, bookie_won, bettor_won
  field :outcome, :type => String, default: :undetermined

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :winner, :polymorphic => true

  # this should be player_1 or player_2 from stream or game_room model
  belongs_to :loser, :polymorphic => true

  # this should be either a stream or a game room
  belongs_to :room, :polymorphic => true

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

  def tooltip_attributes
    [:winner_name, :loser_name, :map, :amount, :odds, :your_risk_amount, :your_win_amount]
  end

  def odds_options
    ['1 to 1', '1 to 5']
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

  def check_winner_and_loser
    errors.add(:loser, "cannot be the same as winner") if winner === loser
  end
end
