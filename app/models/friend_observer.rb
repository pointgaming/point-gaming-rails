class FriendObserver < Mongoid::Observer
  def after_create(record)
    BunnyWrapper.publish_fanout("u.#{record.user._id}", ::RablRails.render(record.friend_user, 'api/v1/friends/new'))
    if record.friend_user.status.eql?("online")
      BunnyWrapper.publish_fanout("u.#{record.user._id}", ::RablRails.render(record.friend_user, 'api/v1/friends/status_changed'))
    end
  end

  def after_destroy(record)
    BunnyWrapper.publish_fanout("u.#{record.user._id}", ::RablRails.render(record.friend_user, 'api/v1/friends/destroy'))
  end
end
