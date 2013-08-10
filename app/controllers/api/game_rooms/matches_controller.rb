module Api
  module GameRooms
    class MatchesController < Api::GameRooms::ContextController
	  before_filter :authenticate_user!, except: [:index] 

	  def update
	  end
    end
  end
end