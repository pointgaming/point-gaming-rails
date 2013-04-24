class NewsCommentsController < ApplicationController
  before_filter :ensure_news
  before_filter :ensure_comment, only: [:edit, :show, :update, :destroy]
  before_filter :ensure_can_edit_comment, only: [:edit, :update]
  before_filter :ensure_can_destroy_comment, only: [:destroy]

  respond_to :html, :json

  def new
    @comment = @news.comments.build
    respond_with(@news, @comment)
  end

  def edit
    respond_with(@news, @comment)
  end

  def show
    respond_with(@news, @comment)
  end

  def create
    @comment = @news.comments.build params[:comment]
    @comment.user = current_user
    @comment.save
    respond_with(@news, @comment, location: news_path(@news, anchor: "comment-#{@comment._id}"))
  end

  def update
    @comment.update_attributes params[:comment]
    respond_with(@news, @comment, location: news_path(@news, anchor: "comment-#{@comment._id}"))
  end

  def destroy
    @comment.destroy
    respond_with(@news)
  end

private

  def ensure_news
    @news = News.find params[:news_id]
  end

  def ensure_comment
    @comment = NewsComment.find params[:id]
  end

  def ensure_can_edit_comment
    raise CanCan::AccessDenied unless can?(:edit, @comment) || can?(:manage, News)
  end

  def ensure_can_destroy_comment
    raise CanCan::AccessDenied unless can?(:destroy, @comment) || can?(:manage, News)
  end

end
