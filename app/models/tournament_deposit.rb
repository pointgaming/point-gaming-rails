class TournamentDeposit
  include Mongoid::Document

  field :amount, type: BigDecimal
  field :total, type: BigDecimal

  belongs_to :tournament
  belongs_to :user

  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :total, presence: true, numericality: {greater_than: 0}
  validates :tournament, presence: true
  validates :user, presence: true
end
