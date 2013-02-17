class HomeController < ApplicationController
  def index
    @news = News.desc(:created_at).all
  end
end
