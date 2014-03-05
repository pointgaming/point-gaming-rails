module Api
  module Games
    class LobbiesController < Api::Games::ContextController
      before_filter :authenticate_rails_app_api!, except: [:ban, :user_rights]
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
	    GameRoom.where(game: @game).where(owner: @user).each { |room| room.delete unless room.team_bot}
	    notify_friends_lobby_changed 'left'

        respond_with :api, @game
	  end

	  def ban
	    @user_lobby = @user.lobbies.where(game: @game).first
	    if @user_lobby.present?
	      period = params[:period].present? ? params[:period].gsub!(',', '.').to_f : 1.0
	      @user_ban = UserBan.where(user: @user_lobby.user, game: @user_lobby.game).first
	      @user_ban = UserBan.create(start_time: Time.now, period: period, game: @user_lobby.game, user: @user_lobby.user) if @user_ban.blank?
	    end
	    respond_with({ is_banned: @user_ban.present? })
	  end

	  def user_rights
	    @answer = {}
	    @answer[:is_banned] = @user.is_banned_for? @game
	    @answer[:can_ban] = !@answer[:is_banned]
	    respond_with @answer
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
