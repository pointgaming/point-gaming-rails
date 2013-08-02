module Api
  module GameRooms
    class ContextController < Api::ApplicationController
      before_filter :authenticate_node_api!
      before_filter :ensure_game_room

      respond_to :json

      protected

       def ensure_game_room
         raise ::UnprocessableEntity, "Missing id parameter" unless game_room_id

         @game_room = GameRoom.find game_room_id
         raise ::UnprocessableEntity, "Invalid id. A game_room with that id was not found." unless @game_room
       end

       def game_room_id
         params[:game_room_id] || params[:id]
       end
    end
  end
end