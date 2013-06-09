class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tournaments = []
  end

  def show
    @tournament = Tournament.find_by(slug: params[:id])
  end

end
