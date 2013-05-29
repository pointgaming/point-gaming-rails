Fabricator(:match) do
  game
  room(fabricator: :stream)
  player_1(fabricator: :user)
  player_2(fabricator: :user)
  map { sequence(:map) { |i| "Shattered Temple#{i}" } }
  default_offerer_odds '1:1'
  match_hash 'rawr'
  state 'new'
end

Fabricator(:one, from: :match) do
  map "Xel'Naga Towers"
end

Fabricator(:team, from: :match) do
  player_1(fabricator: :team)
  player_2(fabricator: :team)
end

Fabricator(:finalized_match, from: :match) do
  player_1(fabricator: :user)
  player_2(fabricator: :user)
  winner {|attrs| attrs[:player_1]}
  state 'finalized'
end
