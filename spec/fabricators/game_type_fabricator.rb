Fabricator(:game_type) do
  name { sequence(:name) { |i| "Counter-Strike: #{i}" } }
  game
end
