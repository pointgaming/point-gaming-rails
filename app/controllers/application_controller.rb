class ApplicationController < ActionController::Base
  include ::SslRequirement
  protect_from_forgery

  self.responder = CustomResponder

  before_filter :authenticate_user!, :if => :requested_private_url?
  around_filter :user_time_zone, :if => :current_user
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

  def current_order
    return @current_order if @current_order

    @current_order = nil
    if session[:order_id]
      current_order = Store::Order.find session[:order_id]
      @current_order = current_order if current_order && current_order.state === 'cart'
    end

    @current_order
  end
  helper_method :current_order

  def desktop_client_latest_version
    SiteSetting.find_by(key: 'desktop_version').value
  rescue Mongoid::Errors::DocumentNotFound
    '0.0.0'
  end
  helper_method :desktop_client_latest_version

private

  def requested_private_url?
    !requested_public_url?
  end

  def requested_public_url?
    request.env['PATH_INFO'].start_with?('/s/') && request.env['PATH_INFO'].ends_with?('/embedded_content')
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def set_current_path
    @current_path = request.fullpath
  end

  def remove_layout_for_ajax_requests
    @is_ajax_request = !!request.xhr?
    self.action_has_layout = false if @is_ajax_request
  end

  def render_unprocessable_entity(exception)
    message = "::UnprocessableEntity raised with message: #{exception.message}"
    Rails.logger.info message
    respond_to do |format|
      # TODO: this is not a good html implementation
      format.html { redirect_to root_path, alert: 'Invalid or missing parameters.' }
      format.json { render json: {message: message}, status: :unprocessable_entity }
    end
  end

  def render_permission_denied
    render :file => "#{Rails.root}/public/403", :status => :forbidden, :layout => false
  end
end
