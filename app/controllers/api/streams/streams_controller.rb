module Api
  module Streams
    class StreamsController < Api::Streams::ContextController
	  def show
	    respond_with(@stream)
	  end

	  def incrementViewerCount
	    raise ::UnprocessableEntity, "Missing count parameter" if params[:count].blank?

	    @stream.increment_viewer_count!(params[:count])

	    respond_with(@stream)
	  end
    end
  end
end