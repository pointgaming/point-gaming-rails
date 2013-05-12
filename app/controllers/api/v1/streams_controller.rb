class Api::V1::StreamsController < Api::ApplicationController
  before_filter :authenticate_node_api!
  before_filter :ensure_stream

  respond_to :json

  def show
    respond_with(@stream)
  end

  def incrementViewerCount
    raise ::UnprocessableEntity, "Missing count parameter" if params[:count].blank?

    @stream.inc :viewer_count, params[:count]

    respond_with(@stream)
  end

protected

  def ensure_stream
    raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

    @stream = Stream.find params[:id]
  end

end
