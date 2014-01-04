class UserPointHistory < UserTransactionHistory

  field :amount, type: Integer
  field :start_balance, type: Integer
  field :end_balance, type: Integer
  field :affected_total_system_points, type: Boolean

  validates :amount, presence: true
  validates :start_balance, presence: true
  validates :end_balance, presence: true

end
