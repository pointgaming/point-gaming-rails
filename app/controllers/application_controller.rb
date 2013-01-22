class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_current_path

  private

  def set_current_path
    @current_path = request.fullpath
  end
end
