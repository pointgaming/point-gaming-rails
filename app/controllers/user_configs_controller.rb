class UserConfigsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_config, only: [:destroy]
  before_filter :ensure_user_id_is_current_user, only: [:new, :create, :destroy]

  def new
    @config = @user.configs.build
  end

  def create
    @config = @user.configs.build(params[:user_config])
    if @config.save
      redirect_to edit_user_profile_path(@user)
    else
      render :action => :new
    end
  end

  def destroy
    @config.destroy

    redirect_to edit_user_profile_path(@user)
  end

protected

  def ensure_user
    @user = User.find params[:user_id]
  end

  def ensure_config
    @config = UserConfig.where(user_id: @user._id).find params[:id]
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user._id
      raise ::PermissionDenied
    end
  end
end
