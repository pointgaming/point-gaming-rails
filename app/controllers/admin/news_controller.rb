class Admin::NewsController < Admin::ApplicationController
  before_filter :ensure_news, only: [:show, :edit, :update, :destroy]
  before_filter :ensure_params, only: [:update, :create]
  authorize_resource

  def index
    @news = News.all
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

    respond_to do |format|
      if @news.save
        format.html { redirect_to admin_news_index_path(@stream), notice: 'News was created successfully.' }
        format.json { render json: true }
      else
        format.html { render action: :new }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @news.update_attributes(params[:news])
        format.html { redirect_to admin_news_index_path(@stream), notice: 'News was updated.' }
        format.json { render json: true }
      else
        format.html { render action: :edit }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @news.destroy
    respond_to do |format|
      format.html { redirect_to admin_news_index_url(@stream) }
      format.json { render json: true }
    end
  end

protected

  def ensure_news
    @news = News.find(params[:id])
  end

  def ensure_params
    if params[:news].blank?
      respond_to do |format|
        format.html { redirect_to admin_news_index_path(@stream), alert: 'Invalid or missing parameters.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
