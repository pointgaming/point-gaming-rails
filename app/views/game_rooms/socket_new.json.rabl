object false
node :action do
  'GameRoom.new'
end
child @object => :data do
  child @object => :game_room do
    extends "game_rooms/base"
  end
end
