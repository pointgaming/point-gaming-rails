class FriendRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create, :update]
  before_filter :ensure_user, :only=>[:create]
  before_filter :ensure_user_not_friend, :only=>[:create]
  before_filter :ensure_friend_request, :only=>[:show, :update, :destroy]
  before_filter :ensure_friend_request_permission, :only=>[:show]
  before_filter :ensure_friend_request_sent_to_current_user, :only=>[:update]
  before_filter :ensure_current_user_owns_friend_request, :only=>[:destroy]

  wrap_parameters :friend_request, :include => [:action]

  def index
    begin
      if params[:sent]
        @friend_requests = FriendRequest.where(user_id: current_user._id).page(params[:page])
      else
        @friend_requests = FriendRequest.where(friend_request_user_id: current_user._id).page(params[:page])
      end
    rescue Mongoid::Errors::DocumentNotFound
      @friend_requests = []
    end
  end

  def create
    @friend_request = FriendRequest.new({user_id: current_user._id, friend_request_user_id: @user._id})
    if @friend_request.save
      redirect_to friend_requests_path
    else
      redirect_to friend_requests_path, alert: 'Failed to create the friend request.'
    end
  end

  def show

  end

  def update

    if params[:friend_request][:action] === 'accept'
      @friend = Friend.new({user_id: @friend_request.friend_request_user_id, friend_user_id: @friend_request.user_id})
      @friend2 = Friend.new({user_id: @friend_request.user_id, friend_user_id: @friend_request.friend_request_user_id})
      if @friend.save && @friend2.save
        @friend_request.destroy
        redirect_to friend_requests_path
      else
        @friend.destroy && @friend2.destroy
        redirect_to friend_requests_path, alert: 'Failed to create the friend relations.'
      end
    elsif params[:friend_request][:action] === 'reject'
      if @friend_request.destroy
        redirect_to friend_requests_path
      else
        redirect_to friend_requests_path, alert: 'Failed to delete the friend request.'
      end
    else
      redirect_to friend_requests_path, alert: 'Invalid friend_request.action'
    end
  end

  def destroy
    if @friend_request.destroy
      redirect_to friend_requests_path, flash: 'Friend request deleted successfully.'
    else
      redirect_to friend_requests_path, alert: 'Failed to delete the friend request.'
    end
  end

  protected

  def ensure_params_exist
    # ugly hack
    if request.GET['action']
      params[:friend_request] ||= {}
      params[:friend_request][:action] = request.GET['action']
    end
    if request.GET['username']
      params[:friend_request] ||= {}
      params[:friend_request][:username] = request.GET['username']
    end

    return unless params[:friend_request].blank?
    redirect_to friend_requests_path, alert: 'Missing friend_request parameter.'
  end

  def ensure_user
    begin
      @user = User.find_by(username: params[:friend_request][:username])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to friend_requests_path, alert: 'That user was not found.'
    end
  end

  def ensure_user_not_friend
    begin
      @friend = Friend.where(user_id: current_user.id).find_by(friend_user_id: @user._id)
      redirect_to friend_requests_path, alert: 'You are already friends with that user.' unless @friend.new_record?
    rescue Mongoid::Errors::DocumentNotFound
      # expected
    end
  end

  def ensure_friend_request
    begin
      @friend_request = FriendRequest.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to friend_requests_path, alert: 'That friend request was not found.'
    end
  end

  def ensure_friend_request_permission
    unless [@friend_request.friend_request_user_id, @friend_request.user_id].include?(current_user._id)
      raise ::PermissionDenied
    end
  end

  def ensure_friend_request_sent_to_current_user
    unless @friend_request.friend_request_user_id === current_user._id
      raise ::PermissionDenied
    end
  end

  def ensure_current_user_owns_friend_request
    unless @friend_request.user_id === current_user._id
      raise ::PermissionDenied
    end
  end
end
