class DemosController < ApplicationController
  ssl_allowed :new, :create, :destroy
  before_filter :authenticate_user!
  before_filter :ensure_demo, only: [:show]
  before_filter :ensure_user_demo, only: [:destroy]
  before_filter :ensure_user_id_is_current_user, only: [:new, :create, :destroy]

  respond_to :html, :json, :js

  def index
    @demos = Demo.order_by(sort_params).all
    respond_with(@demos)
  end

  def show
    DemoDownloadCounter.new(@demo, current_user).count_download
    redirect_to @demo.attachment.url
  end

  def new
    @demo = current_user.demos.build
    respond_with(@demo)
  end

  def create
    @demo = current_user.demos.build(params[:demo])
    puts @demo.save
    respond_with(@demo, location: edit_user_profile_path(current_user))
  end

  def destroy
    @demo.destroy
    respond_with(@demo, location: edit_user_profile_path(current_user))
  end

protected

  def sort_params
    sort_params = {}
    params[:sort] = :updated_at unless params[:sort] === 'download_count'
    sort_params[params[:sort]] = :desc
    sort_params
  end

  def ensure_demo
    @demo = Demo.find params[:id]
  end

  def ensure_user_demo
    @demo = current_user.demos.find params[:id]
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user.slug
      raise ::PermissionDenied
    end
  end
end
