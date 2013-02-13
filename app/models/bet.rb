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
  validates :amount, :presence=>true
  validates :odds, :presence=>true

  def odds_options
    ['1 to 1', '1 to 5']
  end
end
