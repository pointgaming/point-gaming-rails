module Api
  module GameRooms
    class MatchesController < Api::GameRooms::ContextController
	  before_filter :authenticate_user!

	  def index
	  	@matches = pending_user_matches
	  	respond_with :api, @matches
	  end

	  def update
	  end

	  private

	    def pending_user_matches
          bets = current_user_1v1_bets.to_a
          bets |= current_user_team_bets.to_a
          
          swap_bet_match_ancestry bets
	    end

	    def current_user_1v1_bets
          Bet.pending.includes(:match).where('$or' => [{offerer_id: current_user.id}, {taker_id: current_user.id}])
	    end

	    def current_user_team_bets
          Bet.pending.includes(:match).any_in('betters._id' => [current_user.id])
	    end

	    def swap_bet_match_ancestry(bets)
          matches = []
          bets = bets.map{ |b| b.as_json(:include => :match) }
          bets.each do |b|
          	m = b.delete('match')
          	m['bets'] = [b] 
          	matches << m
          end
          matches
	    end
    end
  end
end