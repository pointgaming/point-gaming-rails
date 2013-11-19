module Api
  module Games
    class ContextController < Api::ApplicationController
      before_filter :ensure_game

      respond_to :json

      protected 

    	  def ensure_game
    	    raise ::UnprocessableEntity, "Missing id parameter" if game_id.blank?

    	    @game = Game.find(game_id)
    	  end

        def game_id
          params[:game_id] || params[:id]
        end
    end
  end
end
