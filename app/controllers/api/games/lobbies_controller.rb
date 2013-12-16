module Api
  module Games
    class LobbiesController < Api::Games::ContextController
      before_filter :authenticate_rails_app_api!
      before_filter :ensure_user

	  def join
	    @game.increment_player_count!(1)

	    UserLobby.create(user: @user, game: @game)

	    notify_friends_lobby_changed 'joined'

        respond_with :api, @game
	  end

	  def leave
	    @game.increment_player_count!(-1)
	    @user.lobbies.where(game: @game).destroy_all
	    GameRoom.where(game: @game).where(owner: @user).delete_all
	    notify_friends_lobby_changed 'left'

        respond_with :api, @game
	  end

      protected

        def ensure_user
          raise ::UnprocessableEntity, "Missing user_id parameter" if params[:user_id].blank?
          @user = User.find params[:user_id]
        end

	    def notify_friends_lobby_changed(status)
          uid = @user.id
          gid = @game.id,
	      Resque.enqueue(NotifyFriendLobbyChangeJob, {
	        user_id: uid,
	        game_id: gid,
	        status: status
	      })
	    end
	end
  end
end
