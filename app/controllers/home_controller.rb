class HomeController < ApplicationController

  def index
    @news = News.order_by(created_at: :desc).all
    @demos = Demo.order_by(created_at: :desc).limit(5)
    @players = User.order_by(points: :desc).limit(5)
  end

end
