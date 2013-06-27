class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tournaments = []
  end

  def show
    @tournament = Tournament.find_by(slug: params[:id])
    render 'user_tournaments/show', locals: { hide_workflow: true }
  end

end
