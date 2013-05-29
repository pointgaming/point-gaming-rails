Fabricator(:stream) do
  game
  name { sequence(:name) { |i| "Stream#{i}" } }
  slug { sequence(:slug) { |i| "stream#{i}" } }
  betting true
  streaming true
end
