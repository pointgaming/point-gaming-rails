class TournamentPayment
  include Mongoid::Document

  METHODS = [:bank_account, :dwolla, :paypal, :credit_card]

  field :method
  field :bank_account_number
  field :bank_routing_number
  field :dwolla_id
  field :paypal_email
  field :credit_card_name
  field :credit_card_number
  field :credit_card_expiration_month
  field :credit_card_expiration_year
  field :credit_card_address_1
  field :credit_card_address_2
  field :credit_card_city
  field :credit_card_state
  field :credit_card_zip
  field :amount, type: BigDecimal
  field :fee, type: BigDecimal
  field :total, type: BigDecimal

  belongs_to :tournament
  belongs_to :user

  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :total, presence: true, numericality: {greater_than: 0}
  validates :tournament, presence: true
  validates :user, presence: true

  def bank_account_payment?
    method === 'bank_account'
  end

  def credit_card_payment?
    method === 'credit_card'
  end

  def dwolla_payment?
    method === 'dwolla'
  end

  def paypal_payment?
    method === 'paypal'
  end
end
