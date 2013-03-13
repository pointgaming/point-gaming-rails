class StreamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @streams = Stream.where(streaming: true).all
  end

  def show
    @stream = Stream.find params[:id]
    @stream_owner = @stream.owner
    @collaborator = Collaborator.where(stream_id: @stream._id, user_id: current_user._id)

    if @stream.match
      @bets = Bet.where(match: @stream.match).for_user(current_user).all
    else
      @bets = []
    end
  end
end
