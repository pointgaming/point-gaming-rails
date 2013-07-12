class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @tournaments = Tournament.activated.order_by(start_datetime: :asc).all
    respond_with(@tournaments)
  end

  def show
    @tournament = Tournament.find_by(slug: params[:id])
    respond_with(@tournament)
  end

end
