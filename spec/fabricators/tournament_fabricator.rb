require 'spec_helper'

Fabricator(:tournament) do
  game
  game_type
  name { sequence(:name) { |i| "tournament#{i}" } }
  slug { sequence(:slug) { |i| "tournament#{i}" } }
  start_datetime { DateTime.now }
  signup_start_datetime { DateTime.now }
  signup_end_datetime { DateTime.tomorrow }
  player_limit 128
  format 'single_elimination'
  type 'open'
  maps 'Shattered Temple'
  details 'No cheating!'
end
