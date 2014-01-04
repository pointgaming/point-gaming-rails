class UserObserver < Mongoid::Observer
  def after_update(record)
    if record.status_changed?
      record.friends.each do |friend|
        BunnyWrapper.publish_fanout("u.#{friend.friend_user._id}", ::RablRails.render(record, 'api/v1/friends/status_changed'))
      end
    end
  end
end
