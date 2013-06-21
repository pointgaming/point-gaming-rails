require 'spec_helper'

describe User do
  let(:user) { Fabricate.build(:user) }

  describe "points" do
    it "defaults to 0 points" do
      expect(user.points).to eq(0)
    end

    describe 'increment_points!' do

      it "raises an error with an invalid amount" do
        lambda { user.increment_points!(:wat) }.should raise_error
      end

      it "increments points" do
        user.points = 0

        user.increment_points!(50)
        user.points.should == 50

        user.increment_points!(25)
        user.points.should == 75

        user.increment_points!(-5)
        user.points.should == 70
      end
    end

    describe 'transfer_points_to_user' do
      let(:another_user) { Fabricate.build(:user) }

      it "raises an error with an invalid user" do
        lambda { user.transfer_points_to_user(:wat, 25) }.should raise_error
      end

      it "raises an error with an invalid amount" do
        lambda { user.transfer_points_to_user(another_user, :wat) }.should raise_error
      end

      it "transfers points" do
        user.points = 50
        another_user.points = 0

        user.transfer_points_to_user(another_user, 50)
        user.points.should == 0
        another_user.points.should == 50
      end
    end
  end

  describe "reputation" do
    it "defaults to 100 reputation" do
      expect(user.reputation).to eq(BigDecimal.new("100"))
    end

    describe '#update_reputation' do
      context 'when operands are 0' do
        before(:each) do
          user.match_participation_count = 0
          user.dispute_lost_count = 0
        end

        it 'calculated to 100' do
          user.update_reputation
          expect(user.reputation).to eq(BigDecimal.new("100"))
        end
      end

      context 'when match_participation_count is 0 and dispute_lost_count > 0' do
        before(:each) do
          user.match_participation_count = 0
          user.dispute_lost_count = 1
        end

        it 'calculated to 0' do
          user.update_reputation
          expect(user.reputation).to eq(BigDecimal.new("0"))
        end
      end

      context 'when dispute_lost_count is 0 and match_participation_count > 0' do
        before(:each) do
          user.match_participation_count = 1
          user.dispute_lost_count = 0
        end

        it 'calculated to 100' do
          user.update_reputation
          expect(user.reputation).to eq(BigDecimal.new("100"))
        end
      end

      context 'with ordinary operands' do
        before(:each) do
          user.match_participation_count = 100
          user.dispute_lost_count = 10
        end

        it 'calculates correctly' do
          user.update_reputation
          user.reputation.should === BigDecimal.new("90")
        end
      end
    end
  end

  context '#update_match_participation_count' do
    context 'without any bets' do
      it "doesn't increase the match_participation_count" do
        lambda { user.update_match_participation_count }.should_not change(user, :match_participation_count)
      end
    end

    context 'with finalized bets for one match' do
      let(:match) { Fabricate.build(:match) }
      let(:first_bet) { Fabricate.build(:finalized_bet, taker: user, match: match) }
      let(:second_bet) { Fabricate.build(:finalized_bet, taker: user, match: match) }

      it "increases the match_participation_count by 1" do
        user.stub(:bets).and_return([first_bet, second_bet])
        lambda { user.update_match_participation_count }.should change(user, :match_participation_count).by(1)
      end
    end

    context 'with finalized bets for two matches' do
      let(:first_bet) { Fabricate.build(:finalized_bet, taker: user) }
      let(:second_bet) { Fabricate.build(:finalized_bet, taker: user) }

      it "increases the match_participation_count by 2" do
        user.stub(:bets).and_return([first_bet, second_bet])
        lambda { user.update_match_participation_count }.should change(user, :match_participation_count).by(2)
      end
    end

  end

  context '#team_member?' do
    let(:team) { Fabricate.build(:team) }

    context 'when user is not on team' do
      it 'returns false' do
        expect(user.team_member?(team)).to be_false
      end
    end

    context 'when user is added to the team' do
      it 'returns true' do
        member = user.team_members.build team: team, rank: 'Member'
        member.save
        expect(user.team_member?(team)).to be_true
      end
    end
  end

end
