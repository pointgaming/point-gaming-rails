module Api
  module GameRooms
    class MatchesController < Api::GameRooms::ContextController
    skip_before_filter :ensure_game_room
	  before_filter :authenticate_user!
	  before_filter :ensure_match, only: [:update]

	  def index
	  	@matches = pending_user_matches
	  	respond_with :api, @matches
	  end

	  def update
	  	if can_admin_match?
        if update_match_winner(@match) && update_bet_outcome(@match, @bet)
        	respond_with :api, @match
        else
          render_match_error @match.errors.full_messages
        end
	  	else
	  	  render_unauthorized 
	  	end
	  end

	  private

      def render_match_error(messages)
        render json: {errors: messages}, status: :unprocessable_entity
      end

      def update_match_winner(match)
        match.winner = match.find_participant_for_user(current_user)
        match.save && match.finalize!
      end

      def update_bet_outcome(match, bet)
        bet.outcome = if match.winner == bet.taker_choice
          'taker_won'
        elsif match.winner == bet.offerer_choice
          'offerer_won'
        end
        bet.save
      end

	    def ensure_match
        @bet = current_user_1v1_bets.where(match_id: params[:id]).first
        @bet ||= current_user_team_bets.where(match_id: params[:id]).first
        @match = @bet.match if @bet

        if @match.nil? || @bet.nil?
          render json: {errors: ["The specified bet was not found."]}, status: :unprocessable_entity
        elsif @match.state != 'started'
          render json: {errors: ["Match must be in stated state but was #{@match.state}."]}, status: :unprocessable_entity
	      end
	    end

	    def can_admin_match?
  	      if @match.is_team_vs_mode?
  	      	@bet.betters.map{|b| b.id }.include? current_user.id
	  	  else
	  	  	@bet.offerer_id == current_user.id || @bet.taker_id == current_user.id
	  	  end
	    end

      def started_matches(matches)
        matches.select{|b| b.match.state == 'started' }
      end

	    def pending_user_matches
          bets = current_user_1v1_bets.to_a
          bets |= current_user_team_bets.to_a
          bets = started_matches(bets)
          
          swap_bet_match_ancestry bets
	    end

	    def current_user_1v1_bets
          Bet.pending
             .includes(:match)
             .where('$or' => [{offerer_id: current_user.id}, {taker_id: current_user.id}])
	    end

	    def current_user_team_bets
          Bet.pending
             .includes(:match)
             .any_in('betters._id' => [current_user.id])
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