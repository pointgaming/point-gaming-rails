class FriendRequestObserver < Mongoid::Observer
  def after_create(record)
    BunnyWrapper.publish_fanout("u.#{record.friend_request_user._id}", ::RablRails.render(record, 'api/v1/friend_requests/new'))
    BunnyWrapper.publish_fanout("u.#{record.user._id}", ::RablRails.render(record, 'api/v1/friend_requests/new'))
  end

  def after_destroy(record)
    BunnyWrapper.publish_fanout("u.#{record.friend_request_user._id}", ::RablRails.render(record, 'api/v1/friend_requests/destroy'))
    BunnyWrapper.publish_fanout("u.#{record.user._id}", ::RablRails.render(record, 'api/v1/friend_requests/destroy'))
  end
end
