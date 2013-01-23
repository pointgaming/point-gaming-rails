class Api::V1::FriendsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create, :destroy]
  before_filter :ensure_user, :only=>[:create, :destroy]
  before_filter :ensure_friend, :only=>[:destroy]

  respond_to :json

  def index
    begin
      @friends = Friend.where(user_id: current_user._id).all
      @friends = @friends.map { |friend| friend.friend_user }
      render :json => {:success=>true, :friends=>@friends}
    rescue
      render :json => {:success=>true, :friends=>[]}
    end
  end

  def create
    @friend = Friend.create({user_id: current_user._id, friend_user_id: @user._id})
    if @friend.save
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to create the friend relation", :errors=>@friend.errors}, :status=>500
    end
  end

  def destroy
    if @friend.destroy
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to delete the friend relation", :errors=>@friend.errors}, :status=>500
    end
  end

  protected

  def ensure_params_exist
    return unless params[:user].blank?
    render :json => {:success=>false, :message=>"Missing user parameter"}, :status=>422
  end

  def ensure_user
    begin
      @user = User.find_by(username: params[:user][:username])
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"User not found"}, :status=>404
    end
  end

  def ensure_friend
    begin
      @friend = Friend.find_by(user_id: current_user._id, friend_user_id: @user._id)
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"You are not friends with that user"}, :status=>404
    end
  end
end
