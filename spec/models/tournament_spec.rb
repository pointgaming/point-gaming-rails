require 'spec_helper'

describe Tournament do
  let(:tournament) { Fabricate.build(:tournament) }

  it 'is valid with valid attributes' do
    expect(tournament).to be_valid
  end

  describe "permission checks" do
    let(:tournament) { Fabricate(:tournament) }
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

end
