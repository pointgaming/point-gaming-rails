class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tournaments = Tournament.all
  end

  def show

  end
end
