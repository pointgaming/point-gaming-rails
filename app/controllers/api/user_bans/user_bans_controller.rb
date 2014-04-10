module Api
  module UserBans
    class UserBansController < Api::UserBans::ContextController

	    def index
		@user_ban = UserBan.where(game: @game, user: @user).first
		respond_with :api, @user_ban
	    end
    end
  end
end
