class FriendsController < ApplicationController
  def index
    @friends = current_user.friends.all
    @incoming_friend_requests = FriendRequest.where(friend_request_user_id: current_user.id)
    @outgoing_friend_requests = FriendRequest.where(user_id: current_user.id)
    @blocked_users = []
  end

  def destroy
    @friend = current_user.friends.find(params[:id])

    user_id = @friend.user_id
    friend_user_id = @friend.friend_user_id

    Friend.find_by(user_id: user_id, friend_user_id: friend_user_id).try(:destroy)
    Friend.find_by(user_id: friend_user_id, friend_user_id: user_id).try(:destroy)

    redirect_to friends_path
  end
end
