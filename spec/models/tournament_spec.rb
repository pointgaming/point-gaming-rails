require 'spec_helper'

describe Tournament do
  let(:tournament) { Fabricate(:tournament) }

  describe 'fabrication is valid' do
    let(:tournament) { Fabricate.build(:tournament) }
    it { expect(tournament).to be_valid }
  end

  describe "permission checks" do
    let(:random_user) { Fabricate(:user) }
    let(:owner) { tournament.owner }
    let(:collaborator) do
      Fabricate(:tournament_collaborator, tournament: tournament).user
    end

    describe "#destroyable_by_user?" do
      it "is true for owner" do
        expect(tournament.destroyable_by_user?(owner)).to be_true
      end

      it "is false for a collaborator" do
        expect(tournament.destroyable_by_user?(collaborator)).to be_false
      end

      it "is false for a random user" do
        expect(tournament.destroyable_by_user?(random_user)).to be_false
      end
    end

    describe "#editable_by_user?" do
      it "is true for owner" do
        expect(tournament.editable_by_user?(owner)).to be_true
      end

      it "is true for collaborator" do
        expect(tournament.editable_by_user?(collaborator)).to be_true
      end

      it "is false for a random user" do
        expect(tournament.editable_by_user?(random_user)).to be_false
      end
    end
  end

  describe 'prizepool' do
    context 'is locked in' do
      before do
        tournament.update_attributes(prizepool: {"1" => "1"})
        tournament.save
      end

      it { expect(tournament).to have(0).errors }

      it 'has error when prizepool changed' do
        tournament.prizepool = {"2" => "2"}
        tournament.save

        expect(tournament).to have(1).error_on(:prizepool)
      end
    end
  end

  describe '#update_prizepool_total' do
    let(:tournament) { Fabricate.build(:tournament) }

    context 'with valid prizepool' do
      it 'calculates correctly' do
        tournament.prizepool = {"1" => "5", "2" => "3"}
        tournament.update_prizepool_total

        expect(tournament.prizepool_total).to eq(BigDecimal.new("8"))
      end
    end

    context 'with invalid prizepool' do
      it 'calculates correctly with some invalid input' do
        tournament.prizepool = {"1" => "5", "2" => "2", "3" => "a"}
        tournament.update_prizepool_total

        expect(tournament.prizepool_total).to eq(BigDecimal.new("7"))
      end

      it 'calculates to 0 with invalid input' do
        tournament.prizepool = {"1" => "a", "2" => "b", "3" => "c"}
        tournament.update_prizepool_total

        expect(tournament.prizepool_total).to eq(BigDecimal.new("0"))
      end
    end
  end

end
