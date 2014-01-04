class UserCashHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description
  field :amount, type: BigDecimal

  validates :description, presence: true
  validates :amount, presence: true
end
