require 'spec_helper'

shared_examples_for "tournament_payment_validation" do
  it { expect(tournament_payment).to validate_presence_of(:source) }
  it { expect(tournament_payment).to validate_presence_of(:amount) }
  it { expect(tournament_payment).to validate_presence_of(:total) }
  it { expect(tournament_payment).to validate_presence_of(:tournament) }
  it { expect(tournament_payment).to validate_presence_of(:user) }

  it "validates source is not bogus" do
    tournament_payment.update_attributes source: "chicken"
    expect(tournament_payment).to have(1).error_on(:source)
  end
end

describe TournamentPayment do

  context 'bank_transfer' do
    let(:tournament_payment) { Fabricate.build(:tournament_payment_bank_transfer) }

    it 'fabrication is valid' do
      expect(tournament_payment).to be_valid
    end

    it { expect(tournament_payment).to be_bank_account_payment }
    it { expect(tournament_payment).to_not be_credit_card_payment }
    it { expect(tournament_payment).to_not be_dwolla_payment }
    it { expect(tournament_payment).to_not be_paypal_payment }

    it_behaves_like 'tournament_payment_validation'
    it { expect(tournament_payment).to validate_presence_of(:bank_account_number) }
    it { expect(tournament_payment).to validate_presence_of(:bank_routing_number) }

    describe '#amount=' do
      it 'calls update_total' do
        tournament_payment.should_receive(:update_total)
        tournament_payment.amount = BigDecimal.new("155")
      end

    end
  end

  context 'credit card' do
    let(:tournament_payment) { Fabricate.build(:tournament_payment_credit_card) }

    it 'fabrication is valid' do
      expect(tournament_payment).to be_valid
    end

    it { expect(tournament_payment).to_not be_bank_account_payment }
    it { expect(tournament_payment).to be_credit_card_payment }
    it { expect(tournament_payment).to_not be_dwolla_payment }
    it { expect(tournament_payment).to_not be_paypal_payment }

    it_behaves_like 'tournament_payment_validation'
    it { expect(tournament_payment).to validate_presence_of(:credit_card_number) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_expiration_month) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_expiration_year) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_cvv2) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_address_1) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_city) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_state) }
    it { expect(tournament_payment).to validate_presence_of(:credit_card_zip) }
  end

  context 'dwolla' do
    let(:tournament_payment) { Fabricate.build(:tournament_payment_dwolla) }

    it 'fabrication is valid' do
      expect(tournament_payment).to be_valid
    end

    it { expect(tournament_payment).to_not be_bank_account_payment }
    it { expect(tournament_payment).to_not be_credit_card_payment }
    it { expect(tournament_payment).to be_dwolla_payment }
    it { expect(tournament_payment).to_not be_paypal_payment }

    it_behaves_like 'tournament_payment_validation'
    it { expect(tournament_payment).to validate_presence_of(:dwolla_account_id) }
  end

  context 'paypal' do
    let(:tournament_payment) { Fabricate.build(:tournament_payment_paypal) }

    it 'fabrication is valid' do
      expect(tournament_payment).to be_valid
    end

    it { expect(tournament_payment).to_not be_bank_account_payment }
    it { expect(tournament_payment).to_not be_credit_card_payment }
    it { expect(tournament_payment).to_not be_dwolla_payment }
    it { expect(tournament_payment).to be_paypal_payment }

    it_behaves_like 'tournament_payment_validation'
    it { expect(tournament_payment).to validate_presence_of(:paypal_email) }

    it "validates paypal_email is a valid email" do
      tournament_payment.update_attributes paypal_email: "arrmatey"
      expect(tournament_payment).to have(1).error_on(:paypal_email)
    end
  end

end
