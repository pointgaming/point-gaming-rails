require 'spec_helper'

describe UserPointService do

  describe "#transfer" do
    let(:points_to_transfer) { 50 }
    let(:user) { Fabricate(:user, points: points_to_transfer) }
    let(:another_user) { Fabricate(:user, points: 0) }
    let(:action_source) { Bet.new }

    it "raises an error when transferring points to an invalid user" do
      lambda { UserPointService.new(user).transfer(:wat, 25, action_source) }.should raise_error
    end

    it "raises an error with an invalid amount" do
      lambda { UserPointService.new(user).transfer(another_user, :wat, action_source) }.should raise_error
    end

    it "transfers points" do
      UserPointService.new(user).transfer(another_user, points_to_transfer, action_source)

      user.points.should == 0
      another_user.points.should == points_to_transfer
    end
  end

end
