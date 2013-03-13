class GameRoomsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_room, :only=>[:show]
  before_filter :find_game, :only=>[:show]

  def show
  end

  protected

  def find_game
    @game = Game.find params[:lobby_id]
  end

  def find_room
    @room = GameRoom.find params[:id]
  end
end
