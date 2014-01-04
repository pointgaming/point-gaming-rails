class UserBillingHistory < UserTransactionHistory

  field :amount, type: BigDecimal

  validates :amount, presence: true

end
