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

Fabricator(:user_vs_user_match, from: :match) do
  player_1(fabricator: :user)
  player_2(fabricator: :user)
end

Fabricator(:user_vs_team_match, from: :match) do
  player_1(fabricator: :user)
  player_2(fabricator: :team_with_members)
end

Fabricator(:team_vs_user_match, from: :match) do
  player_1(fabricator: :team_with_members)
  player_2(fabricator: :user)
end

Fabricator(:team_vs_team_match, from: :match) do
  player_1(fabricator: :team_with_members)
  player_2(fabricator: :team_with_members)
end

Fabricator(:finalized_match, from: :match) do
  player_1(fabricator: :user)
  player_2(fabricator: :user)
  winner {|attrs| attrs[:player_1]}
  state 'finalized'
end
