class UserObserver < Mongoid::Observer
  def after_update(record)
    if record.status_changed?
      record.friends.each do |friend|
        action = (record.status === 'online') ? :friend_signed_in : :friend_signed_out
        BunnyClient.instance.publish_fanout("u.#{friend.friend_user.username}", {:action => action, :username => record.username}.to_json)
      end
    end
  end
end
