require 'spec_helper'

describe User do

  describe "points" do
    it "defaults to 0 points" do
      User.new.points.should == 0
    end

    describe 'increment_points!' do
      let(:user) { Fabricate.build(:user) }

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
      let(:user) { Fabricate.build(:user) }
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
    describe '.update_reputation' do
      let(:user) { Fabricate.build(:user) }

      it 'calculates reputation correctly' do
        user.match_participation_count = 100
        user.dispute_lost_count = 10
        user.update_reputation
        user.reputation.should === BigDecimal.new("90")
      end
    end
  end

  context '.update_match_participation_count' do
    let(:user) { Fabricate.build(:user) }

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

end
