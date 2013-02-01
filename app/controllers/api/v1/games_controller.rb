class Api::V1::GamesController < Api::ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def index
    begin
      @games = Game.all
      render :json => {:success=>true, :games=>@games}
    rescue
      render :json => {:success=>true, :games=>[]}
    end
  end
end
