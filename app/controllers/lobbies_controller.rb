class LobbiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_game, :only=>[:show]

  def show
    @rooms = @game.rooms
  end

  protected

  def find_game
    @game = Game.find params[:id]
  end
end
