module Api
  module GameRooms
    class GameRoomsController < Api::GameRooms::ContextController
      before_filter :authenticate_node_api!
      before_filter :ensure_user, only: [:join, :leave]

      def show
        @game_room.matches = @game_room.pending_matches
        json = @game_room.as_json(:methods => [:bets])

        respond_with(json)
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

      def ensure_game_room
        if params[:id].present?
          @game_room = GameRoom.find params[:id]
        else
          respond_with({errors: ["Missing id parameter"]}, status: 403)
        end
      end

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