class UserTournamentsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @tournaments = Tournament.all
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(create_params)
    @tournament.save
    respond_with(@tournament, location: edit_user_tournament_path(@tournament.id))
  end

  def edit
    @tournament = Tournament.find params[:id]
  end

private

  def create_params
    params[:tournament]
  end

end
