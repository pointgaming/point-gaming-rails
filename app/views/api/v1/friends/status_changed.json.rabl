object false
node :action do
  'friend_status_changed'
end
child @object => :user do
  attributes :_id, :username, :status
  child :lobbies do
    attributes :game_id
  end
end
