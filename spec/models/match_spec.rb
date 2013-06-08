require 'spec_helper'

describe Match do

  describe "is_team_vs_mode?" do
    let(:match) {Fabricate.build(:match) }

    it "is true when there are two teams" do
      match.player_1 = Fabricate.build(:team)
      match.player_2 = Fabricate.build(:team)
      match.is_team_vs_mode?.should be_true
    end

    it "is true when there is at least one team" do
      match.player_1 = Fabricate.build(:team)
      match.player_2 = Fabricate.build(:user)
      match.is_team_vs_mode?.should be_true
    end

    it "is true when there is at least one team" do
      match.player_1 = Fabricate.build(:user)
      match.player_2 = Fabricate.build(:team)
      match.is_team_vs_mode?.should be_true
    end

    it "is false when there are two users" do
      match.player_1 = Fabricate.build(:user)
      match.player_2 = Fabricate.build(:user)
      match.is_team_vs_mode?.should be_false
    end
  end

  describe '.can_be_disputed_by?' do
    context 'when User vs User match' do
      let(:match) { Fabricate.build(:user_vs_user_match) }

      it 'is false for some random user' do
        user = Fabricate.build(:user)
        match.can_be_disputed_by?(user).should be_false
      end

      it 'is true for match.player_1' do
        match.can_be_disputed_by?(match.player_1).should be_true
      end

      it 'is true for match.player_2' do
        match.can_be_disputed_by?(match.player_2).should be_true
      end
    end

    context 'when User vs Team match' do
      let(:match) { Fabricate(:user_vs_team_match) }

      it 'is false for some random user' do
        user = Fabricate.build(:user)
        match.can_be_disputed_by?(user).should be_false
      end

      it 'is true for match.player_1' do
        match.can_be_disputed_by?(match.player_1).should be_true
      end

      it 'is false for match.player_2 team members' do
        member = match.player_2.members.where(rank: 'Member').first
        match.can_be_disputed_by?(member.user).should be_false
      end

      it 'is true for the match.player_2 team managers' do
        manager = match.player_2.members.where(rank: 'Manager').first
        match.can_be_disputed_by?(manager.user).should be_true
      end

      it 'is true for the match.player_2 team leader' do
        leader = match.player_2.members.where(rank: 'Leader').first
        match.can_be_disputed_by?(leader.user).should be_true
      end

    end

    context 'when Team vs Team match' do
      let(:match) { Fabricate(:team_vs_team_match) }

      it 'is false for some random user' do
        user = Fabricate.build(:user)
        match.can_be_disputed_by?(user).should be_false
      end

      it 'is false for match.player_1 team members' do
        member = match.player_1.members.where(rank: 'Member').first
        match.can_be_disputed_by?(member.user).should be_false
      end

      it 'is true for the match.player_1 team managers' do
        manager = match.player_1.members.where(rank: 'Manager').first
        match.can_be_disputed_by?(manager.user).should be_true
      end

      it 'is true for the match.player_1 team leader' do
        leader = match.player_1.members.where(rank: 'Leader').first
        match.can_be_disputed_by?(leader.user).should be_true
      end

      it 'is false for match.player_2 team members' do
        member = match.player_2.members.where(rank: 'Member').first
        match.can_be_disputed_by?(member.user).should be_false
      end

      it 'is true for the match.player_2 team managers' do
        manager = match.player_2.members.where(rank: 'Manager').first
        match.can_be_disputed_by?(manager.user).should be_true
      end

      it 'is true for the match.player_2 team leader' do
        leader = match.player_2.members.where(rank: 'Leader').first
        match.can_be_disputed_by?(leader.user).should be_true
      end

    end
  end

end
