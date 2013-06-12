Fabricator(:game_room) do
  betting true
  position { sequence(:position) { |i| i + 1 } }
  game
  owner(fabricator: :user)
end
