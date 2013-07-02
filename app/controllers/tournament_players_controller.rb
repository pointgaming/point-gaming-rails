class TournamentPlayersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_tournament_signup_open, only: [:create]
  before_filter :ensure_tournament_player, only: [:destroy]

  respond_to :html, :json

  def create
    @player = TournamentPlayer.new({tournament_id: @tournament._id, user_id: current_user._id})
    @player.save
    respond_with(@player, location: tournament_path(@tournament.slug))
  end

  def destroy
    @tournament_player.destroy
    respond_with(@tournament_player, location: tournament_path(@tournament.slug))
  end

protected

  def ensure_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def ensure_tournament_signup_open
    unless @tournament.signup_open?
      message = 'That tournament is no longer open for registration'
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
