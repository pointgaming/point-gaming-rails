class FriendRequestObserver < Mongoid::Observer
  def after_create(record)
    BunnyClient.instance.publish_fanout("u.#{record.friend_request_user.username}", ::RablRails.render(record, 'api/v1/friend_requests/new'))
    BunnyClient.instance.publish_fanout("u.#{record.user.username}", ::RablRails.render(record, 'api/v1/friend_requests/new'))
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("u.#{record.friend_request_user.username}", ::RablRails.render(record, 'api/v1/friend_requests/destroy'))
    BunnyClient.instance.publish_fanout("u.#{record.user.username}", ::RablRails.render(record, 'api/v1/friend_requests/destroy'))
  end
end
