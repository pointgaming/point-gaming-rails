object false
child(:@friends) do
  attributes :_id, :username, :status, :avatar
  child :lobbies do
    attributes :game_id
  end
end
