class FriendLobbyChangeMessage
  attr_reader :action, :data

  def initialize(opts)
    @action = 'Friend.Lobby.change'
    @data = {
      game_id: opts.fetch(:game_id),
      user_id: opts.fetch(:user_id),
      status: opts.fetch(:status)
    }
  end

end
