class HomeController < ApplicationController
  def index
    @news = News.desc(:created_at).all
    @tournaments = Tournament.all
  end
end
