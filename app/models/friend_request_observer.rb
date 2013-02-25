class FriendRequestObserver < Mongoid::Observer
  def after_create(record)
    BunnyClient.instance.publish_fanout("u.#{record.friend_request_user.username}", ::RablRails.render(record.user, 'api/v1/friend_requests/new'))
  end
end
