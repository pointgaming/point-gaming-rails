class TournamentPlayersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_user_can_join_tournament, only: [:create]
  before_filter :ensure_user_can_check_in_to_tournament, only: [:update]
  before_filter :ensure_user_can_leave_tournament, only: [:destroy]
  before_filter :ensure_tournament_player, only: [:update, :destroy]

  respond_to :html, :json

  def create
    @player = TournamentPlayer.new({tournament_id: @tournament._id, user_id: current_user._id})
    @player.save
    respond_with(@player, location: tournament_path(@tournament.slug))
  end

  def update
    @tournament_player.update_attributes(checked_in_at: DateTime.now)
    respond_with(@tournament_player, location: tournament_path(@tournament.slug))
  end

  def destroy
    @tournament_player.destroy
    respond_with(@tournament_player, location: tournament_path(@tournament.slug))
  end

  private

  def ensure_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def tournament_player_policy
    @tournament_player_policy ||= TournamentPlayerPolicy.new(current_user, @tournament)
  end

  def ensure_user_can_join_tournament
    unless tournament_player_policy.join?
      message = 'That tournament is no longer open for registration'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_user_can_check_in_to_tournament
    unless tournament_player_policy.check_in?
      message = 'Failed to check in to tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_user_can_leave_tournament
    unless tournament_player_policy.leave?
      message = 'Failed to leave tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

  def ensure_tournament_player
    @tournament_player = @tournament.players.for_user(current_user).first
    unless @tournament_player.present?
      message = 'Permission Denied'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournament_path(@tournament.slug), alert: message }
      end
    end
  end

end
