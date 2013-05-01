class BlockedUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create]
  before_filter :ensure_user, :only=>[:create]
  before_filter :ensure_blocked_user, :only=>[:destroy]

  respond_to :html, :json

  def index
    @blocked_users = current_user.blocked_users.all
    respond_with(@blocked_users)
  end

  def create
    @blocked_user = BlockedUser.create({user_id: current_user._id, blocked_user_id: @user._id})
    @blocked_user.save
    respond_with(@blocked_user) do |format|
      format.html { redirect_to :back }
    end
  end

  def destroy
    @blocked_user.destroy
    respond_with(@blocked_user) do |format|
      format.html { redirect_to :back }
    end
  end

protected

  def ensure_params_exist
    if params[:blocked_user].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing blocked_user parameter' }
      end
    end
  end

  def ensure_user
    begin
      @user = User.find_by(username: params[:blocked_user][:username])
    rescue Mongoid::Errors::DocumentNotFound
      respond_with(nil, status: 404) do |format|
        format.html { redirect_to :back, alert: 'That user was not found' }
      end
    end
  end

  def ensure_blocked_user
    begin
      @blocked_user = current_user.blocked_users.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      respond_with(nil, status: 404) do |format|
        format.html { redirect_to :back, alert: 'That user was not blocked' }
      end
    end
  end

end
