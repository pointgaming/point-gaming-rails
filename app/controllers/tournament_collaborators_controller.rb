class TournamentCollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_tournament_owner
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_user, only: [:create]
  before_filter :ensure_collaborator, only: [:destroy]

  respond_to :html, :json

  def new
    @collaborator = @tournament.collaborators.build
    respond_with(@collaborator)
  end

  def create
    @collaborator = @tournament.collaborators.build(params[:tournament_collaborator])
    @collaborator.save
    respond_with(@collaborator, location: users_user_tournament_path(@tournament))
  end

  def destroy
    @collaborator.destroy
    respond_with(@collaborator, location: users_user_tournament_path(@tournament))
  end

protected

  def ensure_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def ensure_tournament_owner
    unless @tournament.owner._id === current_user._id
      message = 'You do not have permission to edit that tournaments collaborators'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

  def ensure_params
    if params[:tournament_collaborator].blank?
      message = 'Missing tournament_collaborator parameter'
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to users_user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:tournament_collaborator][:username]).first
    unless @user
      message = 'The specified user was not found.'
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to users_user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_collaborator
    @collaborator = @tournament.collaborators.find(params[:id])
  end

end
