class Admin::ApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin

  def sub_layout
    "admin"
  end

private

  def ensure_admin
    raise ::PermissionDenied unless current_user.admin?
  end
end
