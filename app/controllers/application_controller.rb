class ApplicationController < BaseController
  self.responder = CustomResponder

  before_filter :authenticate_user!, :if => :requested_private_url?
  around_filter :user_time_zone, :if => :current_user
  before_filter :set_current_path

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

  def requested_private_url?
    !requested_public_url?
  end

  def requested_public_url?
    false
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def set_current_path
    @current_path = request.fullpath
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
