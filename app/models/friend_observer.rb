class FriendObserver < Mongoid::Observer
  def after_create(record)
    BunnyClient.instance.publish_fanout("u.#{record.user.username}", {:action => :new_friend, :username => record.friend_user.username}.to_json)
  end
end
