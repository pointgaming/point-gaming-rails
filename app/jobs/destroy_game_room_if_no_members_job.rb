class DestroyGameRoomIfNoMembersJob
  @queue = :high

  def self.perform(value)
    game_room = GameRoom.find(value)
    game_room.destroy if game_room.member_count == 0
  rescue Mongoid::Errors::DocumentNotFound

  end
end
