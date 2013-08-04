module Api
  module GameRooms
    class GameRoomsController < Api::GameRooms::ContextController
      before_filter :authenticate_user!, only: [:create]
      before_filter :authenticate_node_api!, except: [:create]
      before_filter :ensure_user, only: [:join, :leave]
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

        respond_with(@game_room)
      end      

      def destroy
        @game_room.destroy
        respond_with(@game_room)
      end

      def join
        @game_room.add_user_to_members!(@user)
        respond_with(@game_room)
      end

      def leave
        @game_room.remove_user_from_members!(@user)
        respond_with(@game_room)
      end

    protected

      def ensure_user
        if params[:user_id].present?
          @user = User.find params[:user_id]
        else
          respond_with({errors: ["Missing user_id parameter"]}, status: 403)
        end
      end
    end
  end
end