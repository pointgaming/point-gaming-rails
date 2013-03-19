class Api::ApplicationController < ActionController::Base
  rescue_from ::PermissionDenied, :with => :render_permission_denied
  rescue_from ::UnprocessableEntity, :with => :render_unprocessable_entity

private

  def render_unprocessable_entity
    respond_to do |format|
      format.json { render json: [], status: :unprocessable_entity }
    end
  end

  def render_permission_denied
    render :file => "#{Rails.root}/public/403", :status => :forbidden, :layout => false
  end
end
