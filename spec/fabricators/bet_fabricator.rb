Fabricator(:bet) do
  match
  offerer_choice {|attrs| attrs[:match].player_1}
  taker_choice {|attrs| attrs[:match].player_2}
  offerer(fabricator: :user)
  taker(fabricator: :user)
  offerer_odds '1:1'
  taker_odds '1:1'
  offerer_wager '1'
  taker_wager '1'
  match_hash {|attrs| attrs[:match].match_hash}
end

Fabricator(:finalized_bet, from: :bet) do
  outcome 'taker_won'
  state 'finalized'
end
