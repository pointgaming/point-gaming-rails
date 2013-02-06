class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_current_path

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
end
