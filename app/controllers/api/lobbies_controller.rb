class Api::LobbiesController < Api::ApplicationController
  before_filter :authenticate_rails_app_api!
  before_filter :ensure_game
  before_filter :ensure_user

  respond_to :json

  def join
    @game.increment_player_count!(1)

    UserLobby.create(user: @user, game: @game)

    notify_friends_lobby_changed({
      user_id: @user.id,
      game_id: @game._id,
      status: 'joined'
    })

	  respond_with(@game)
  end

  def leave
    @game.increment_player_count!(-1)

    @user.lobbies.where(game: @game).destroy_all

    notify_friends_lobby_changed({
      user_id: @user.id,
      game_id: @game._id,
      status: 'left'
    })

	  respond_with(@game)
  end

  private

  def ensure_user
    if params[:user_id].blank?
      raise ::UnprocessableEntity, "Missing user_id parameter"
    end

    @user = User.find(params[:user_id])
  end

  def ensure_game
    raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

    @game = Game.find(params[:id])
  end

  def notify_friends_lobby_changed(opts)
    Resque.enqueue(NotifyFriendLobbyChangeJob, {
      user_id: opts.fetch(:user_id),
      game_id: opts.fetch(:game_id),
      status: opts.fetch(:status)
    })
  end

end
