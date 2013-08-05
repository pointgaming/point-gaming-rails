class Api::V1::FriendsController < Api::ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def index
    begin
      @friends = Friend.where(user_id: current_user._id).all
      @friends = @friends.map { |friend| friend.friend_user }

      respond_with(@friends)
    rescue
      render :json => {:friends=>[]}
    end
  end

  def destroy
    begin
      @friend = Friend.find_by(user_id: current_user._id, friend_user_id: params[:id])
      @friend2 = Friend.where(user_id: @friend.friend_user_id, friend_user_id: current_user._id)
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"Invalid friend id"}, :status=>404
      return
    end

    if @friend.destroy && @friend2.destroy
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to delete the friend relation", :errors=>[@friend.errors,@friend2.errors]}, :status=>500
    end
  end
end
