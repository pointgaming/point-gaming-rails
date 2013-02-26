class Api::V1::FriendRequestsController < Api::ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create, :update]
  before_filter :ensure_user, :only=>[:create]
  before_filter :ensure_user_not_friend, :only=>[:create]
  before_filter :ensure_friend_request, :only=>[:show, :update, :destroy]
  before_filter :ensure_friend_request_permission, :only=>[:show]
  before_filter :ensure_friend_request_sent_to_current_user, :only=>[:update]
  before_filter :ensure_current_user_owns_friend_request, :only=>[:destroy]

  respond_to :json

  def index
    @sent = params[:sent]
    begin
      if @sent
        @friend_requests = FriendRequest.where(user_id: current_user._id).all
      else
        @friend_requests = FriendRequest.where(friend_request_user_id: current_user._id).all
      end

      respond_with(@friend_requests)
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>true, :friend_requests=>[]}
    end
  end

  def create
    @friend_request = FriendRequest.new({user_id: current_user._id, friend_request_user_id: @user._id})
    if @friend_request.save
      respond_with(@friend_request)
    else
      render :json => {:success=>false, :message=>"Failed to create the friend request", :errors=>@friend_request.errors}, :status=>500
    end
  end

  def show
    respond_with(@friend_request)
  end

  def update
    if params[:friend_request][:action] === 'accept'
      @friend = Friend.new({user_id: @friend_request.friend_request_user_id, friend_user_id: @friend_request.user_id})
      @friend2 = Friend.new({user_id: @friend_request.user_id, friend_user_id: @friend_request.friend_request_user_id})
      if @friend.save && @friend2.save
        @friend_request.destroy
        render :json => {:success=>true}
      else
        @friend.destroy && @friend2.destroy
        render :json => {:success=>false, :message=>"Failed to create the friend relations", :errors=>[@friend.errors,@friend2.errors]}, :status=>500
      end
    elsif params[:friend_request][:action] === 'reject'
      if @friend_request.destroy
        render :json => {:success=>true}
      else
        render :json => {:success=>false, :message=>"Failed to delete the friend request", :errors=>@friend_request.errors}, :status=>500
      end
    else
      render :json => {:success=>false, :message=>"Invalid friend_request.action", :errors=>@friend_request.errors}, :status=>422
    end
  end

  def destroy
    if @friend_request.destroy
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to delete the friend request", :errors=>@friend_request.errors}, :status=>500
    end
  end

  protected

  def ensure_params_exist
    return unless params[:friend_request].blank?
    render :json => {:success=>false, :message=>"Missing friend_request parameter"}, :status=>422
  end

  def ensure_user
    begin
      @user = User.find_by(username: params[:friend_request][:username])
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"User not found"}, :status=>404
    end
  end

  def ensure_user_not_friend
    begin
      @friend = Friend.where(user_id: current_user.id).find_by(friend_user_id: @user._id)
      render :json => {:success=>false, :message=>"You are already friends with that user"}, :status=>404 unless @friend.new_record?
    rescue Mongoid::Errors::DocumentNotFound
      # expected
    end
  end

  def ensure_friend_request
    begin
      @friend_request = FriendRequest.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"That friend request was not found"}, :status=>404
    end
  end

  def ensure_friend_request_permission
    unless [@friend_request.friend_request_user_id, @friend_request.user_id].include?(current_user._id)
      render :json => {:success=>false, :message=>"You do not have permission to access that friend request"}, :status=>403
    end
  end

  def ensure_friend_request_sent_to_current_user
    unless @friend_request.friend_request_user_id === current_user._id
      render :json => {:success=>false, :message=>"You do not have permission to access that friend request"}, :status=>403
    end
  end

  def ensure_current_user_owns_friend_request
    unless @friend_request.user_id === current_user._id
      render :json => {:success=>false, :message=>"You do not have permission to access that friend request"}, :status=>403
    end
  end
end
