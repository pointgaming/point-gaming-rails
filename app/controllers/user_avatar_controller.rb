class UserAvatarController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_params, only: [:update]
  before_filter :ensure_user_id_is_current_user, only: [:edit, :update]

  respond_to :html, :json

  def edit
    respond_with(@user)
  end

  def update
    @user.update_attributes(update_params)
    respond_with(@user, location: edit_user_profile_path(@user))
  end

protected

  def ensure_params
    if params[:user].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing user parameter' }
      end
    end
  end

  def update_params
    params[:user].slice(:avatar)
  end

  def ensure_user
    @user = User.find_by slug: params[:user_id]
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user.slug
      raise ::PermissionDenied
    end
  end
end
