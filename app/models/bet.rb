class Bet
  include Mongoid::Document

  field :winner, :type => String
  field :loser, :type => String
  field :map, :type => String
  field :amount, :type => Integer
  field :odds, :type => String

  belongs_to :stream

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
    [:winner, :loser, :map, :amount, :odds, :your_risk_amount, :your_win_amount]
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

  def check_winner_and_loser
    errors.add(:loser, "cannot be the same as winner") if winner === loser
  end
end
