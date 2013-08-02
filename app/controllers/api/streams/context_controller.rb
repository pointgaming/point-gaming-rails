module Api
  module Streams
    class ContextController < Api::ApplicationController
      before_filter :authenticate_node_api!
      before_filter :ensure_stream

      respond_to :json

      protected

        def ensure_stream
          raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

          @stream = Stream.find params[:id]
        end
    end
  end
end