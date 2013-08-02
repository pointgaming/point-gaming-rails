module Api
  module GameRooms
    class BetsController < Api::GameRooms::ContextController
	  before_filter :authenticate_user!
	  before_filter :ensure_params, only: [:create]
	  before_filter :ensure_bet_match, only: [:create]
	  before_filter :ensure_bet, only: [:create]
	  before_filter :ensure_offerer_choice, only: [:create]
	  before_filter :ensure_taker_choice, only: [:create]

	  def create
	    @bet.offerer = current_user

	    @bet.match = @match
	    @bet.offerer_odds = @match.default_offerer_odds
	    @bet.match_hash = @match.match_hash

	    @bet.save
	    respond_with :api, @game_room, @bet
	  end

	  def show
	  end

      protected

  	    def ensure_params
 	      if params[:bet].blank?
	        respond_to do |format|
	          format.html { redirect_to polymorphic_path(@game_room), alert: 'Invalid or missing parameters.' }
              format.json { render json: [], status: :unprocessable_entity }
	        end
	      end
	    end

	    def ensure_bet
          @bet = Bet.new(params[:bet])
	    end

	    def ensure_bet_match
	      if params[:bet][:match]
	      	@match = Match.new params[:bet][:match]
	      	@match.room_type = 'GameRoom'
	      	@match.room = @game_room
	      	@match.game = @game_room.game
	      	@match.player_1 = current_user

	      	if !@match.save
              render json: {errors: ["Invalid match: #{@match.errors.full_messages.join(', ')}"]}, status: 403
	      	end
	      else
	      	render json: {errors: ["Missing match parameter"]}, status: 403
	      end
	    end

	    def ensure_offerer_choice
	      if ['player_1', 'player_2'].include?(params[:bet][:offerer_choice])
	        if @offerer_choice = @match.send(params[:bet][:offerer_choice])
			  @bet.offerer_choice = @offerer_choice
			  @bet.offerer_choice_name = @offerer_choice.try(:display_name)
			end
          else
	        nil
	      end
	    end

        def ensure_taker_choice
	      if ['player_1', 'player_2'].include?(params[:bet][:taker_choice])
	        if @taker_choice = @match.send(params[:bet][:taker_choice])
              @bet.taker_choice = @taker_choice
	          @bet.taker_choice_name = @taker_choice.try(:display_name)
	        end
          else
	        nil
	      end
        end
    end
  end
end