class StreamsController < ApplicationController
  before_filter :authenticate_user!, except: [:embedded_content]
  before_filter :ensure_stream, only: [:show, :embedded_content]

  def index
    @streams = Stream.where(streaming: true).order_by(viewer_count: 'DESC').all
  end

  def show
    @stream_owner = @stream.owner
    @collaborator = Collaborator.where(stream_id: @stream._id, user_id: current_user._id)

    if @stream.match
      @bets = Bet.pending.where(match: @stream.match).for_user(current_user).all
    else
      @bets = []
    end
  end

  def embedded_content
    render "embedded_content", layout: false
  end

private

  def ensure_stream
    @stream = Stream.where(slug: params[:id]).first
    raise Mongoid::Errors::DocumentNotFound unless @stream.present?
  end

end
