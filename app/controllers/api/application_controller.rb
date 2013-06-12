class Api::ApplicationController < ActionController::Base
  include ::SslRequirement
  rescue_from ::PermissionDenied, :with => :render_permission_denied
  rescue_from ::UnprocessableEntity, :with => :render_unprocessable_entity
  rescue_from ::Mongoid::Errors::DocumentNotFound, :with => :render_not_found

  self.responder = CustomResponder

protected

  def ssl_required?
    true
  end

  def api_token_present?
    params[:api_token].present?
  end

  def valid_api_token?(token)
    api_token_present? && params[:api_token] === token
  end

  def authenticate_node_api!
    render_unauthorized unless valid_api_token?(APP_CONFIG['node_api_auth_token'])
  end

  def authenticate_store_api!
    render_unauthorized unless valid_api_token?(APP_CONFIG['store_api_auth_token'])
  end

  def authenticate_forum_api!
    render_unauthorized unless valid_api_token?(APP_CONFIG['forum_api_auth_token'])
  end

  def authenticate_rails_app_api!
    render_unauthorized unless valid_api_token?(APP_CONFIG['store_api_auth_token']) || 
                               valid_api_token?(APP_CONFIG['forum_api_auth_token'])
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
