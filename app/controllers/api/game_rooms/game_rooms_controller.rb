module Api
  module GameRooms
    class GameRoomsController < Api::GameRooms::ContextController
      before_filter :authenticate_user!, only: [:create, :update]
      before_filter :authenticate_node_api!, except: [:create, :update, :take_over]
      before_filter :ensure_user, only: [:join, :leave]
      before_filter :ensure_params, only: [:create, :update]
      before_filter :check_owner_params, only: [:update]
      skip_before_filter :ensure_game_room, only: [:create]

      def show
        @game_room.matches = @game_room.pending_matches
        json = @game_room.as_json(:methods => [:bets])

        respond_with(json)
      end

      def create
        @game_room = GameRoom.new(params[:game_room])
        @game_room.game = @game_room.game
        @game_room.owner = current_user
        @game_room.save

        respond_with :api, @game_room
      end

      def update
        params[:game_room].delete(:game_id)
        params[:game_room].delete(:owner_id)
        @game_room.owner = @owner unless @owner.nil?

        @game_room.update_attributes(params[:game_room])
        respond_with :api, @game_room
      end

      def destroy
        @game_room.destroy
        respond_with :api, @game_room
      end

      def join
        @game_room.add_user_to_members!(@user)
        respond_with(@game_room)
      end

      def leave
        @game_room.remove_user_from_members!(@user)
        respond_with(@game_room)
      end

      def take_over
	@game_room = GameRoom.find params[:id]
	if @game_room && !current_user.eql?(@game_room.owner) && current_user.can_take_over?(@game_room)
	  @new_game_room = @game_room.clone
	  @new_game_room.owner = current_user
	  @game_room.update_attributes position: GameRoom.first_free_position(@game_room.game)
	  @new_game_room.save
	  respond_with :api, @new_game_room
	else
	  respond_with({ errors: ["You cannot take this room over"] }, status: 403)
	end
      end

    protected

      def ensure_user
        if params[:user_id].present?
          @user = User.find params[:user_id]
        else
          respond_with({errors: ["Missing user_id parameter"]}, status: 403)
        end
      end

      def ensure_params
        raise ::UnprocessableEntity, "Missing game_room parameter" if params[:game_room].blank?
      end

      def check_owner_params
        return unless params[:game_room][:owner_id]

        @owner = User.find(params[:game_room][:owner_id])
        raise ::UnprocessableEntity, "Invalid owner_id. A user with that id was not found." unless @owner
      end
    end
  end
end
