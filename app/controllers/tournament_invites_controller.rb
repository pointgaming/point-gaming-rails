class TournamentInvitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_tournament_owner
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_user, only: [:create]
  before_filter :ensure_invite, only: [:destroy]

  respond_to :html, :json

  def create
    @invite = TournamentInvite.new({tournament_id: @tournament._id, user_id: @user._id})
    @invite.save
    respond_with(@invite, location: users_user_tournament_path(@tournament))
  end

  def destroy
    @invite.destroy
    respond_with(@invite, location: users_user_tournament_path(@tournament))
  end

protected

  def ensure_tournament
    @tournament = Tournament.find(params[:user_tournament_id])
  end

  def ensure_tournament_owner
    unless @tournament.owner._id === current_user._id
      message = 'You do not have permission to edit that tournaments invites'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

  def ensure_params
    if params[:tournament_invite].blank?
      message = 'Missing tournament_invite parameter'
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to users_user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:tournament_invite][:username]).first
    unless @user
      message = 'The specified user was not found.'
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to users_user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_invite
    @invite = @tournament.invites.find(params[:id])
  end

end
