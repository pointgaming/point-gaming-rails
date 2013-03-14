class Admin::GroupUsersController < Admin::ApplicationController
  before_filter :ensure_group
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

    unless @group
      respond_to do |format|
        format.html { redirect_to edit_admin_group_path(@group), alert: "Invalid gorup." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user_lookup
    params[:user][:username] ||= nil
    @user = User.where(username: params[:user][:username]).first

    unless @user
      respond_to do |format|
        format.html { redirect_to edit_admin_group_path(@group), alert: "The specified user was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user
    @user = User.find(params[:id])

    unless @user
      respond_to do |format|
        format.html { redirect_to edit_admin_group_path(@group), alert: "The specified user was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user_not_in_group
    unless @user.group.nil?
      respond_to do |format|
        format.html { redirect_to edit_admin_group_path(@group), alert: "The specified user is already in a group." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
