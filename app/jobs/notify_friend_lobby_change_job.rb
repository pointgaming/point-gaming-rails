class NotifyFriendLobbyChangeJob
  @queue = :high

  def self.perform(opts)
    user_id = opts.fetch('user_id')
    game_id = opts.fetch('game_id')
    status = opts.fetch('status')

    user = lookup_user(user_id)

    message = build_message(user_id, game_id, status)

    friend_users_by_user(user).each do |friend|
      notify_friend(friend, message)
    end
  end

  private

  def self.lookup_user(id)
    User.find(id)
  end

  def self.build_message(user_id, game_id, status)
    FriendLobbyChangeMessage.new({
      user_id: user_id,
      game_id: game_id,
      status: status
    }).to_json
  end

  def self.friend_users_by_user(user)
    user.friends.map(&:friend_user)
  end

  def self.notify_friend(user, message)
    MessagesUser.new({ user: user, message: message }).send
  end

end
