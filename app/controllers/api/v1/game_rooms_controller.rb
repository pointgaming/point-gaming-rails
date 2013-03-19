class Api::V1::GameRoomsController < Api::ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_game_params, only: [:index]
  before_filter :ensure_game, only: [:create]
  before_filter :ensure_game_room, except: [:new, :create, :index]
  before_filter :check_owner_params, only: [:update]
  before_filter :ensure_params, only: [:create, :update]

  respond_to :json

  def index
    @game_rooms = GameRoom.for(@game).order_by(position: 'ASC').all
    respond_with(@game_rooms)
  end

  def show
    respond_with(@game_room)
  end

  def create
    @game_room = GameRoom.new(params[:game_room])
    @game_room.game = @game
    @game_room.owner = current_user

    @game_room.save
    respond_with(@game_room, location: api_v1_game_room_path(@game._id, @game_room._id))
  end

  def update
    params[:game_room].delete(:game_id)
    params[:game_room].delete(:owner_id)
    @game_room.owner = @owner unless @owner.nil?
    @game_room.update_attributes(params[:game_room])
    respond_with(@game_room, location: api_v1_game_room_path(@game_room.game_id, @game_room._id))
  end

protected

  def ensure_game_params
    raise ::UnprocessableEntity if params[:game_id].blank?

    @game = Game.find(params[:game_id])
    raise ::UnprocessableEntity unless @game
  end

  def ensure_game
    raise ::UnprocessableEntity if params[:game_room][:game_id].blank?

    @game = Game.find(params[:game_room][:game_id])
    raise ::UnprocessableEntity unless @game
  end

  def ensure_game_room
    raise ::UnprocessableEntity if params[:id].blank?

    @game_room = GameRoom.find params[:id]
    raise ::UnprocessableEntity unless @game_room
  end

  def check_owner_params
    return unless params[:game_room][:owner_id]

    @owner = User.find(params[:game_room][:owner_id])
    raise ::UnprocessableEntity unless @owner
  end

  def ensure_params
    raise ::UnprocessableEntity if params[:game_room].blank?
  end
end
