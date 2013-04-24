class NewsController < ApplicationController
  before_filter :ensure_news, only: [:show]

  respond_to :html, :json

  def show
    @comment = NewsComment.new
    respond_with(@news)
  end

private

  def ensure_news
    @news = News.find params[:id]
  end

end
