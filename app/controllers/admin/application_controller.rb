class Admin::ApplicationController < ApplicationController
  include ::SslRequirement

  before_filter :authenticate_user!
  before_filter :ensure_admin

  def sub_layout
    "admin"
  end

protected

  def ssl_required?
    true
  end

  def ensure_admin
    raise ::PermissionDenied unless current_user.admin?
  end
end
