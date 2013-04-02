class Api::ApplicationController < ActionController::Base
  rescue_from ::PermissionDenied, :with => :render_permission_denied
  rescue_from ::UnprocessableEntity, :with => :render_unprocessable_entity
  rescue_from ::Mongoid::Errors::DocumentNotFound, :with => :render_not_found

private

  def authenticate_node_api
    params[:api_token] && params[:api_token] === APP_CONFIG['node_api_auth_token']
  end

  def authenticate_node_api!
    render_unauthorized unless authenticate_node_api
  end

  def authenticate_store_api
    params[:api_token] && params[:api_token] === APP_CONFIG['store_api_auth_token']
  end

  def authenticate_store_api!
    render_unauthorized unless authenticate_spree_api
  end

  def authenticate_forum_api
    params[:api_token] && params[:api_token] === APP_CONFIG['forum_api_auth_token']
  end

  def authenticate_forum_api!
    render_unauthorized unless authenticate_forum_api
  end

  def authenticate_rails_app_api
    authenticate_store_api || authenticate_forum_api
  end

  def authenticate_rails_app_api!
    render_unauthorized unless authenticate_rails_app_api
  end

  def render_not_found
    render json: {}, status: 404
  end

  def render_unauthorized
    render json: {}, status: 401
  end

  def render_unprocessable_entity
    respond_to do |format|
      format.json { render json: [], status: :unprocessable_entity }
    end
  end

  def render_permission_denied
    render :file => "#{Rails.root}/public/403", :status => :forbidden, :layout => false
  end

end
