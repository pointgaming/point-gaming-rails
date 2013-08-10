module Api
  module Games
    class GamesController < Api::Games::ContextController
	  def index
	    @games = Game.all
	    render :json => {:success=>true, :games=>@games}
	  end
	end
  end
end