require 'spec_helper'

describe Tournament do
  let(:tournament) { Fabricate.build(:tournament) }

  it { expect(tournament).to validate_presence_of(:name) }
  it { expect(tournament).to validate_presence_of(:slug) }
  it { expect(tournament).to validate_presence_of(:signup_start_datetime) }
  it { expect(tournament).to validate_presence_of(:signup_end_datetime) }
  it { expect(tournament).to validate_presence_of(:start_datetime) }
  it { expect(tournament).to validate_presence_of(:player_limit) }
  it { expect(tournament).to validate_presence_of(:format) }
  it { expect(tournament).to validate_presence_of(:type) }
  it { expect(tournament).to validate_presence_of(:game) }
  it { expect(tournament).to validate_presence_of(:game_type) }
  it { expect(tournament).to validate_presence_of(:maps) }
  it { expect(tournament).to validate_presence_of(:details) }

  context 'without prizepool configured' do
    it 'has a valid fabrication' do
      expect(tournament).to be_valid
    end
  end

  describe '#prizepool_submitted!' do
    let(:tournament) { Fabricate(:tournament) }
    let!(:outcome) { tournament.prizepool_submitted! }

    it { expect(outcome).to be_false }

    it 'Adds prizepool required error' do
      expect(tournament.errors[:prizepool]).to include('is required')
    end
  end

  describe 'permission checks' do
    let(:tournament) { Fabricate(:tournament) }
    let(:random_user) { Fabricate.build(:user) }
    let(:owner) { tournament.owner }
    let(:collaborator) do
      Fabricate(:tournament_collaborator, tournament: tournament).user
    end

    describe 'destroyable_by_user?' do
      it 'is true for owner' do
        expect(tournament.destroyable_by_user?(owner)).to be_true
      end

      it 'is false for a collaborator' do
        expect(tournament.destroyable_by_user?(collaborator)).to be_false
      end

      it 'is false for a random user' do
        expect(tournament.destroyable_by_user?(random_user)).to be_false
      end
    end

    describe 'editable_by_user?' do
      it 'is true for owner' do
        expect(tournament.editable_by_user?(owner)).to be_true
      end

      it 'is true for collaborator' do
        expect(tournament.editable_by_user?(collaborator)).to be_true
      end

      it 'is false for a random user' do
        expect(tournament.editable_by_user?(random_user)).to be_false
      end
    end
  end

  describe 'with prizepool configured' do
    before do
      tournament.update_attributes(prizepool: {'1' => '500'})
    end

    it 'moved to payment_required state' do 
      expect(tournament.state).to eq('payment_required')
    end

    context 'when prizepool is changed' do
      before { tournament.prizepool = {'2' => '31'} }

      it 'saving tournament should fail' do 
        expect(tournament.save).to be_false
      end

      it 'tournament should have errors on the prizepool field' do
        tournament.save
        expect(tournament).to have(1).error_on(:prizepool)
      end
    end

    describe '#payment_submitted!' do
      let!(:outcome) { tournament.payment_submitted! }

      it { expect(outcome).to be_false }

      it 'Adds payment required error' do
        expect(tournament.errors[:payment]).to include('is required')
      end
    end
  end

  describe 'with payment configured' do
    before do
      tournament.update_attributes(prizepool: {'1' => '500'})
      payment = Fabricate(:tournament_payment_credit_card, tournament: tournament)
    end

    it 'moved to payment_pending state' do 
      expect(tournament.state).to eq('payment_pending')
    end

  end

  describe 'prizepool=' do
    it 'calls update_prizepool_total once' do
      tournament.should_receive(:update_prizepool_total).once
      tournament.prizepool = {'1' => '5', '2' => '3'}
    end

    context 'with valid prizepool' do
      before { tournament.prizepool = {'1' => '5', '2' => '3'} }

      it 'calculates total' do
        expect(tournament.prizepool_total).to eq(BigDecimal.new('8'))
      end
    end

    context 'with some invalid input' do
      before { tournament.prizepool = {'1' => '5', '2' => '2', '3' => 'a'} }

      it 'calculates total for valid values' do
        expect(tournament.prizepool_total).to eq(BigDecimal.new('7'))
      end
    end

    context 'with all invalid input' do
      before { tournament.prizepool = {'1' => 'a', '2' => 'b', '3' => 'c'} }

      it 'calculates total to 0' do
        expect(tournament.prizepool_total).to eq(BigDecimal.new('0'))
      end
    end
  end

end
