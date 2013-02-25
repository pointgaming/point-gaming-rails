class UserProfilesController < ApplicationController
  before_filter :authenticate_user!, except: [:subregion_options]
  before_filter :ensure_user, except: [:subregion_options]
  before_filter :ensure_user_profile, except: [:subregion_options]
  before_filter :ensure_friends, except: [:subregion_options]
  before_filter :ensure_user_id_is_current_user, only: [:edit, :update]

  def show
    @matches = []
  end

  def edit

  end

  def update
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    if @user.update_attributes(params[:user])
      redirect_to user_profile_path(@user)
    else
      render :action => :edit
    end
  end

  def subregion_options
    render partial: 'subregion_select'
  end

protected

  def ensure_user
    @user = User.find params[:user_id]
  end

  def ensure_user_profile
    unless @user.profile
      @user.build_profile.save
      @user.save
    end
    unless @user.profile.rig
      @user.profile.build_rig
    end
  end

  def ensure_friends
    @friends = Friend.where(user_id: @user._id).all.map { |friend| friend.friend_user }
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user._id
      raise ::PermissionDenied
    end
  end
end