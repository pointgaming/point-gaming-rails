Fabricator(:tournament) do
  game
  game_type
  name { sequence(:name) { |i| "tournament#{i}" } }
  starts_at { Time.now + 2.hours }
  player_limit 16
  format "double_elimination"
  type "open"
  details "No WD!!!"
  owner Fabricate(:user, username: "tourney_owner")
end
