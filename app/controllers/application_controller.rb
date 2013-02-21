class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_current_path
  before_filter :remove_layout_for_ajax_requests

  rescue_from ::PermissionDenied, :with => :render_permission_denied

  def after_sign_in_path_for(resource)
    session[:email] = resource.email

    @auth_token = resource.auth_tokens.build
    session[:auth_token] = @auth_token._id if @auth_token.save
    root_path
  end

private

  def set_current_path
    @current_path = request.fullpath
  end

  def remove_layout_for_ajax_requests
    @is_ajax_request = request.xhr?
    self.action_has_layout = false if @is_ajax_request
  end

  def render_permission_denied
    render :file => "#{Rails.root}/public/403.html", :status => :forbidden, :layout => false
  end
end
