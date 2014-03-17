module Api
  module UserBans
    class ContextController < Api::ApplicationController
      before_filter :ensure_user
      before_filter :ensure_game

      respond_to :json

      protected

      def ensure_game
        raise ::UnprocessableEntity, "Missing id parameter" if params[:game_id].blank?

	@game = Game.find(params[:game_id])
      end

      def ensure_user
	raise ::UnprocessableEntity, "Mising user_id parameter" if params[:user_id].blank?

	@user = User.find(params[:user_id])
      end
    end
  end
end
