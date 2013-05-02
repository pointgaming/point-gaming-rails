class Admin::GroupUsersController < Admin::ApplicationController
  before_filter :ensure_group
  before_filter :ensure_username_params, only: [:create]
  before_filter :ensure_user_lookup, only: [:create]
  before_filter :ensure_user, only: [:destroy]
  before_filter :ensure_user_not_in_group, only: [:create]

  respond_to :html, :json

  def create
    @user.group = @group
    @user.save
    respond_with(@user, location: edit_admin_group_url(@group))
  end

  def destroy
    @user.group = nil
    @user.save
    respond_with(@user, location: edit_admin_group_url(@group))
  end

protected

  def ensure_group
    @group = Group.find params[:group_id]
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(@group, status: :unprocessable_entity) do |format|
      format.html { redirect_to :back, alert: "Invalid gorup" }
    end
  end

  def ensure_username_params
    params[:user][:username] ||= nil
  end

  def ensure_user_lookup
    @user = User.find_by(username: params[:user][:username])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(@user, status: :unprocessable_entity) do |format|
      format.html { redirect_to :back, alert: "The specified user was not found" }
    end
  end

  def ensure_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(@user, status: :unprocessable_entity) do |format|
      format.html { redirect_to :back, alert: "The specified user was not found" }
    end
  end

  def ensure_user_not_in_group
    if @user.group.present?
      respond_with(nil, status: :unprocessable_entity) do |format|
        format.html { redirect_to :back, alert: "The specified user is already in a group" }
      end
    end
  end
end
