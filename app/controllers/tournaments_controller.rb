class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tournaments = []
  end

  def show
    @tournament = Tournament.find params[:id]
  end

end
