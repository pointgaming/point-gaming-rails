object false
node :action do
  'GameRoom.update'
end
child @object => :data do
  extends "api/v1/game_rooms/base"
end
