module Api
  module Friends
    class ContextController < Api::ApplicationController
      before_filter :authenticate_user!

      respond_to :json

      protected

        def ensure_friends
          @friends = Friend.where(user_id: current_user._id).all
          @friends = @friends.map { |friend| friend.friend_user }
        rescue
          @friends = []
        end


        def ensure_friend_request
          @friend_request = FriendRequest.find(params[:id])
        rescue Mongoid::Errors::DocumentNotFound
          render :json => {:success=>false, :message=>"That friend request was not found"}, :status=>404
        end
    end
  end
end