module Admin
  class NewsController < Admin::ApplicationController
    before_filter :ensure_news, only: [:show, :edit, :update, :destroy]
    before_filter :ensure_params, only: [:update, :create]

    respond_to :html

    def index
      @news = News.order_by(created_at: :desc)
    end

    def new
      @news = News.new
    end

    def edit
    end

    def show
    end

    def create
      @news = News.new(params[:news])
      flash[:notice] = "News was successfully deleted." if @news.save
      respond_with(@news, location: admin_news_index_path)
    end

    def update
      flash[:notice] = "News was successfully deleted." if @news.update_attributes(params[:news])
      respond_with(@news, location: admin_news_index_path)
    end

    def destroy
      flash[:notice] = "News was successfully deleted." if @news.destroy
      respond_with(@news, location: admin_news_index_path)
    end

    protected

    def ensure_news
      @news = News.find(params[:id])
    end

    def ensure_params
      redirect_to admin_news_index_path, alert: "Invalid or missing parameters." if params[:news].blank?
    end
  end
end
