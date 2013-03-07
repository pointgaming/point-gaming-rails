class StreamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @streams = Stream.where(streaming: true).all
  end

  def show
    @stream = Stream.find params[:id]
    @stream_owner = @stream.owner
    @collaborator = Collaborator.where(stream_id: @stream._id, user_id: current_user._id)
    @bets = Bet.where(room: @stream).any_of({:bettor_id.in => [current_user._id, nil]}, {bookie_id: current_user._id}).all
  end
end
