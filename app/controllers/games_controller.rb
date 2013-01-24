class GamesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @games = Game.all
  end
end
