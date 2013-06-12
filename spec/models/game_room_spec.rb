require 'spec_helper'

describe GameRoom do
  let(:game) { Fabricate(:game) }

  describe 'after_create #ensure_game_room_has_members' do
    before { ResqueSpec.reset! }
    let(:game_room) { Fabricate.build(:game_room, game: game) }

    it 'schedules DestroyGameRoomIfNoMembers' do
      game_room.save
      expect(DestroyGameRoomIfNoMembers).to have_scheduled(game_room._id)
    end
  end

  describe '#destroy_if_no_members' do
    let(:game_room) { create_game_room_with_members }

    context "when all members leave" do
      before(:each) do
        game_room.members.each do |user|
          game_room.remove_user_from_members!(user)
        end
      end

      it "is deleted from the database" do
        expect{ game_room.reload }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when one member leaves" do
      let!(:initial_member_count) { game_room.member_count }
      before(:each) do
        game_room.remove_user_from_members!(game_room.members.first)
        game_room.reload
      end

      it "is not deleted from the database" do
        expect(game_room).to be_present
      end

      it "member_count is reduced by 1" do
        expect(game_room.member_count).to eq(initial_member_count - 1)
      end
    end
  end

end

def create_game_room_with_members(options={})
  game_room = Fabricate(:game_room, options)
  game_room.add_user_to_members!(Fabricate(:user))
  game_room.add_user_to_members!(Fabricate(:user))
  game_room
end
