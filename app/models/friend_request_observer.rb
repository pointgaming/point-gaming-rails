class FriendRequestObserver < Mongoid::Observer
  def after_create(record)
    BunnyClient.instance.publish_fanout("u.#{record.friend_request_user.username}", {:action => :new_friend_request, :username => record.user.username}.to_json)
  end
end
