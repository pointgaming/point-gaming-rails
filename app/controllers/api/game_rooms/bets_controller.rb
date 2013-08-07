module Api
  module GameRooms
    class BetsController < Api::GameRooms::ContextController
	  before_filter :authenticate_user!, except: [:index] 
	  before_filter :ensure_params, only: [:create, :update]
	  before_filter :ensure_bet_match, only: [:create]
	  before_filter :ensure_game_room_bet, only: [:show]
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
        render json: @bet.as_json(:include => :match), status: 200
	  end

	  def index
	  	@bets = Bet.where(:match_id.in => @game_room.match_ids)
	  	respond_with :api, @bets
	  end

	  def update
	  	if @bet.match.is_new_state?
	  	else
	  	end
	  end

	  def destroy
	  	if @bet.match.is_new_state? && can_admin_bet?
          render_success
	  	else
	  	  render_unauthorized 
	  	end
	  end

      protected

  	    def ensure_params
 	      render_unprocessable_entity if params[:bet].blank?
	    end

	    def ensure_game_room_bet
          @bet = Bet.where(id: params[:id]).first
          unless @bet && @bet.match.room == @game_room
            render json: {errors: ["The specified bet was not found."]}, status: :unprocessable_entity
          end
	    end

	    def ensure_bet
          @bet = Bet.where(match: @match).find params[:id]
          unless @bet
            render json: {errors: ["The specified bet was not found."]}, status: :unprocessable_entity
	      end
	    end

	    def ensure_bet_match
          @bet = Bet.new(params[:bet])
          if !@game_room.match.nil?
	      	render json: {errors: ["The room already has a match"]}, status: :unprocessable_entity
	      elsif @game_room.betting == false
            render json: {errors: ["Betting not avalable in room."]}, status: :unprocessable_entity
	      elsif !@game_room.is_1v1? && current_user.team.nil?
            render json: {errors: ["No player team available for team bet."]}, status: :unprocessable_entity
	      elsif params[:bet][:match]
	      	@match = Match.new params[:bet][:match]
	      	@match.room_type = 'GameRoom'
	      	@match.room = @game_room
	      	@match.game = @game_room.game
	      	@match.default_offerer_odds ||= params[:bet][:offerer_odds]
	      	@match.player_1 = @game_room.is_1v1? ? current_user : current_user.team

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

      private

        def can_admin_bet?
          @bet.game_room.owner == current_user || @bet.offerer == current_user
        end
    end
  end
end