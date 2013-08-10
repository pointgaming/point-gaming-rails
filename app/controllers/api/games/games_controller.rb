module Api
  module Games
    class GamesController < Api::Games::ContextController
      skip_before_filter :ensure_game, only: [:index]
      
	  def index
	    @games = Game.all
	    render :json => {:success=>true, :games=>@games}
	  end
	end
  end
end