Fabricator(:payment) do
  amount BigDecimal.new("10")
  fee BigDecimal.new("5")
  total BigDecimal.new("15")

  tournament

  after_build do |payment, attrs|
    payment.tournament = payment.tournament || Fabricate.build(:tournament)
    payment.user = payment.tournament.collaborators.first
  end
end

Fabricator(:payment_bank_transfer, from: :payment) do
  source "bank_account"
  bank_account_number "0123123123"
  bank_routing_number "1231231234"
end

Fabricator(:payment_credit_card, from: :payment) do
  source "credit_card"
  credit_card_name "James Bond"
  credit_card_number "4111111111111111"
  credit_card_expiration_month "07"
  credit_card_expiration_year "14"
  credit_card_cvv2 "112"
  credit_card_address_1 "123 Big Walk Way"
  credit_card_address_2 "Apt 1"
  credit_card_city "Texas City"
  credit_card_state "Texas"
  credit_card_zip "77591"
end

Fabricator(:payment_dwolla, from: :payment) do
  source "dwolla"
  dwolla_account_id "1333224423"
end

Fabricator(:payment_paypal, from: :payment) do
  source "paypal"
  paypal_email "testuser@gmail.com"
end
