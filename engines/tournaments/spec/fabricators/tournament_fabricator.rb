Fabricator(:tournament) do
  game
  game_type
  name { sequence(:name) { |i| "tournament#{i}" } }
  stream_slug { sequence(:stream_slug) { |i| "stream#{i}" } }
  signup_ends_at { Time.now + 2.hours }
  player_limit 128
  format "double_elimination"
  type "open"
  details "No WD!!!"
  owner Fabricate(:user, username: "tourney_owner")
end
