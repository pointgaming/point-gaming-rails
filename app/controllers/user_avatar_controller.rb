class UserAvatarController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_user_id_is_current_user, only: [:edit, :update]

  def edit

  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to edit_user_profile_path(@user)
    else
      render :action => :edit
    end
  end

protected

  def ensure_user
    @user = User.find params[:user_id]
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user._id
      raise ::PermissionDenied
    end
  end
end
