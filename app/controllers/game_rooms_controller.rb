class GameRoomsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_game_params, only: [:index]
  before_filter :ensure_game_room, except: [:new, :index]

  respond_to :json

  def index
    @game_rooms = GameRoom.for(@game).order_by(position: 'ASC').all
    respond_with(@game_rooms)
  end

  def show
    respond_with(@game_room)
  end

protected

  def ensure_game_params
    raise ::UnprocessableEntity, "Missing game_id parameter" if params[:game_id].blank?

    @game = Game.find(params[:game_id])
    raise ::UnprocessableEntity, "Invalid game_id. A game with that game_id was not found." unless @game
  end

  def ensure_game_room
    raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

    @game_room = GameRoom.find params[:id]
    raise ::UnprocessableEntity, "Invalid id. A game_room with that id was not found." unless @game_room
  end

end
