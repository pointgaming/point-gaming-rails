class Payment
  include Mongoid::Document

  SOURCES = [:bank_account, :dwolla, :paypal, :credit_card]

  after_create :move_tournament_to_next_state!

  field :source
  field :bank_account_number
  field :bank_routing_number
  field :dwolla_account_id
  field :paypal_email
  field :credit_card_name
  field :credit_card_number
  field :credit_card_expiration_month
  field :credit_card_expiration_year
  field :credit_card_cvv2
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
  validates :source, presence: true
  validates :bank_account_number, presence: true, if: :bank_account_payment?
  validates :bank_routing_number, presence: true, if: :bank_account_payment?
  validates :credit_card_name, presence: true, if: :credit_card_payment?
  validates :credit_card_number, presence: true, if: :credit_card_payment?
  validates :credit_card_expiration_month, presence: true, if: :credit_card_payment?
  validates :credit_card_expiration_year, presence: true, if: :credit_card_payment?
  validates :credit_card_cvv2, presence: true, if: :credit_card_payment?
  validates :credit_card_address_1, presence: true, if: :credit_card_payment?
  validates :credit_card_state, presence: true, if: :credit_card_payment?
  validates :credit_card_city, presence: true, if: :credit_card_payment?
  validates :credit_card_zip, presence: true, if: :credit_card_payment?
  validates :dwolla_account_id, presence: true, if: :dwolla_payment?
  validates :paypal_email, presence: true, email_format: true, if: :paypal_payment?
  validates :tournament, presence: true
  validates :user, presence: true
  validate :verify_source

  def amount=(value)
    write_attribute(:amount, value)
    update_fee
  end

  def update_fee
    self.fee = BigDecimal.new("0")
    update_total
  end

  def update_total
    self.total = amount + fee
  end

  SOURCES.each do |src|
    define_method "#{source}_payment?" do
      self.source.to_s == src.to_s
    end
  end

  private

  def verify_source
    if source.present?
      self.errors[:source] << "is invalid" unless SOURCES.include?(source.to_s.to_sym)
    end
  end

  def move_tournament_to_next_state!
    tournament.payment_submitted! if tournament.payment_required?
  end
end
