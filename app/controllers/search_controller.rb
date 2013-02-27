class SearchController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def index
    @results = []
    @results += User.where(username: /#{Regexp.escape(params[:query])}/i).all
    @results += Team.where(name: /#{Regexp.escape(params[:query])}/i).all
    @results += Stream.where(name: /#{Regexp.escape(params[:query])}/i).all
    @results += Game.where(name: /#{Regexp.escape(params[:query])}/i).all

    Kaminari.paginate_array(@results).page(params[:page])

    respond_with(@results)
  end

  def playable
    @results = []
    @results += User.where(username: /#{Regexp.escape(params[:query])}/i).all
    @results += Team.where(name: /#{Regexp.escape(params[:query])}/i).all

    Kaminari.paginate_array(@results).page(params[:page])

    respond_with(@results)
  end
end
