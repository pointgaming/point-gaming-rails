Fabricator(:game) do
  name { sequence(:name) { |i| "Counter-Strike: #{i}" } }
end
