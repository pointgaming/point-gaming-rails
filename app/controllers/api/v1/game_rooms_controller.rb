class Api::V1::GameRoomsController < Api::ApplicationController
  before_filter :authenticate_node_api!
  before_filter :ensure_game_room

  respond_to :json

  def show
    respond_with(@game_room)
  end

  def destroy
    @game_room.destroy
    respond_with(@game_room)
  end

protected

  def ensure_game_room
    raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

    @game_room = GameRoom.find params[:id]
  end

end
