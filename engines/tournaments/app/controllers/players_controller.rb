class PlayersController < EngineController
  before_filter :ensure_tournament
  before_filter :ensure_user_can_join_tournament, only: [:create]
  before_filter :ensure_user_can_check_in_to_tournament, only: [:update]
  before_filter :ensure_user_can_leave_tournament, only: [:destroy]
  before_filter :ensure_tournament_player, only: [:update, :destroy]

  respond_to :html, :json

  def create
    @player = Player.create({tournament_id: @tournament._id, user_id: current_user._id})
    respond_with(@player, location: @tournament)
  end

  def update
    @tournament_player.update_attributes(checked_in_at: DateTime.now)
    respond_with(@tournament_player, location: @tournament)
  end

  def destroy
    @tournament_player.destroy
    respond_with(@tournament_player, location: @tournament)
  end

  private

  def tournament_player_policy
    @tournament_player_policy ||= TournamentPlayerPolicy.new(current_user, @tournament)
  end

  def ensure_user_can_join_tournament
    unless current_user.can?(:join, @tournament)
      message = "That tournament is no longer open for registration"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_user_can_check_in_to_tournament
    unless check_in?
      message = "Failed to check in to tournament"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_user_can_leave_tournament
    unless leave?
      message = "Failed to leave tournament"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_tournament_player
    @tournament_player = @tournament.players.for_user(current_user).first
    unless @tournament_player.present?
      message = "Permission Denied"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def join?
    @tournament.signup_open? && !user_signed_up_for_tournament?
  end

  def leave?
    user_signed_up_for_tournament?
  end

  def signed_up?
    user_signed_up_for_tournament?
  end

  def check_in?
    @tournament.checkin_open_for?(current_user)
  end

  def checked_in?
    user_signed_up_for_tournament? && user_checked_in_for_tournament?
  end

  def tournament_player_for_user
    @tournament_player_for_user ||= @tournament.players.for_user(current_user).first
  end

  def user_signed_up_for_tournament?
    tournament_player_for_user.present?
  end

  def user_checked_in_for_tournament?
    tournament_player_for_user.checked_in?
  end
end
