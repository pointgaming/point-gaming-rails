class ApplicationController < ActionController::Base
  protect_from_forgery

  self.responder = CustomResponder

  before_filter :set_current_path
  before_filter :remove_layout_for_ajax_requests

  rescue_from ::PermissionDenied, :with => :render_permission_denied
  rescue_from ::UnprocessableEntity, :with => :render_unprocessable_entity

  def after_sign_in_path_for(resource)
    session[:email] = resource.email

    @auth_token = resource.auth_tokens.build
    session[:auth_token] = @auth_token._id if @auth_token.save
    root_path
  end

  def render(options = nil, extra_options = {}, &block)
    options ||= {}
    options = options.merge({formats: [:modal, :rabl, :json, :html]}) if @is_ajax_request
    super(options, extra_options, &block)
  end

private

  def set_current_path
    @current_path = request.fullpath
  end

  def remove_layout_for_ajax_requests
    @is_ajax_request = !!request.xhr?
    self.action_has_layout = false if @is_ajax_request
  end

  def render_unprocessable_entity
    respond_to do |format|
      # TODO: this is not a good html implementation
      format.html { redirect_to root_path, alert: 'Invalid or missing parameters.' }
      format.json { render json: [], status: :unprocessable_entity }
    end
  end

  def render_permission_denied
    render :file => "#{Rails.root}/public/403", :status => :forbidden, :layout => false
  end
end
