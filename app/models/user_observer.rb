class UserObserver < Mongoid::Observer
  def after_update(record)
    if record.status_changed?
      record.friends.each do |friend|
        BunnyClient.instance.publish_fanout("u.#{friend.friend_user.username}", ::RablRails.render(record, 'api/v1/friends/status_changed'))
      end
    end
  end
end
