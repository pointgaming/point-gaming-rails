class StreamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @streams = Stream.all
  end

  def show
    @stream = Stream.find params[:id]
    @stream_owner = @stream.owner
    @bets = Bet.where(stream_id: @stream._id).any_of({:bettor_id.in => [current_user._id, nil]}, {bookie_id: current_user._id}).all
  end
end
