object false
node :action do
  'GameRoom.destroy'
end
child @object => :data do
  extends "api/v1/game_rooms/base"
end
