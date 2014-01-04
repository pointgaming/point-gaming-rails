object false
node :action do
  'GameRoom.update'
end
child @object => :data do
  child @object => :game_room do
    extends "game_rooms/base"
  end
end
