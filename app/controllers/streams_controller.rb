class StreamsController < ApplicationController
  before_filter :authenticate_user!, except: [:embedded_content]
  before_filter :ensure_stream, only: [:show, :embedded_content]

  respond_to :html, :json

  def index
    @streams = Stream.where(streaming: true).order_by(viewer_count: 'DESC').all
    @featured = @streams[0..3]
    respond_with(@streams)
  end

  def search
    params[:query] ||= ""
    @streams = Stream.where(name: /#{Regexp.escape(params[:query])}/i).page(params[:page])
    render json: @streams, only: [:_id, :name]
  end

  def show
    @stream_owner = @stream.owner
    @collaborator = Collaborator.where(stream_id: @stream._id, user_id: current_user._id)

    if @stream.match
      @bets = Bet.pending.where(match: @stream.match).available_for_user(current_user).all
    else
      @bets = []
    end
  end

  def embedded_content
    render "embedded_content", layout: false
  end

private

  def ensure_stream
    @stream = Stream.find_by(slug: params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    message = 'That stream was not found'
    respond_with({ errors: [message] }, status: 404) do |format|
      format.html { redirect_to streams_path, alert: message }
    end
  end

end
