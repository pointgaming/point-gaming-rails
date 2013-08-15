require 'spec_helper'

describe DestroyGameRoomIfNoMembersJob do
  let(:game) { Fabricate(:game) }
  let(:game_room) { Fabricate(:game_room, game: game) }

  context 'when game_room has no members' do
    before(:each) { DestroyGameRoomIfNoMembersJob.perform(game_room._id) }

    it 'is deleted' do
      expect{ game_room.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  context 'when game_room has members' do
    let(:user) { Fabricate(:user) }
    before(:each) { game_room.add_user_to_members!(user) }
    before(:each) { DestroyGameRoomIfNoMembersJob.perform(game_room._id) }

    it 'is not deleted' do
      game_room.reload
      expect(game_room).to be_present
    end
  end
end
