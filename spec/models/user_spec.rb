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

end
