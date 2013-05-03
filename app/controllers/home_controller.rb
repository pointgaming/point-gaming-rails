class HomeController < ApplicationController
  def index
    @news = News.desc(:created_at).all
    @tournaments = Tournament.all
    @players = User.order_by(points: :desc).limit(5)
  end
end
