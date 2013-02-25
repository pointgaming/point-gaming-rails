class FriendObserver < Mongoid::Observer
  def after_create(record)
    BunnyClient.instance.publish_fanout("u.#{record.user.username}", ::RablRails.render(record.friend_user, 'api/v1/friends/new'))
    if record.friend_user.status.eql?("online")
      BunnyClient.instance.publish_fanout("u.#{record.user.username}", ::RablRails.render(record.friend_user, 'api/v1/friends/status_changed'))
    end
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("u.#{record.user.username}", ::RablRails.render(record.friend_user, 'api/v1/friends/destroy'))
  end
end
