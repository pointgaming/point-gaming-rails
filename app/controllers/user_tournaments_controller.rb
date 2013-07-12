class UserTournamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament, except: [:index, :new, :create]

  before_filter :ensure_tournament_prizepool_required, only: [:prize_pool]
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update]
  before_filter :ensure_tournament_destroyable_by_user, only: [:destroy]

  respond_to :html, :json

  def index
    @tournaments = TournamentCollaborator.for_user(current_user).all.map(&:tournament)
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(create_params)
    collaborator = TournamentCollaborator.new(tournament_id: @tournament._id, user_id: current_user.id, owner: true)
    @tournament.save && collaborator.save
    respond_with(@tournament, location: edit_user_tournament_path(@tournament.id))
  end

  def show
  end

  def edit
  end

  def update
    @tournament.update_attributes(update_params)
    respond_with(@tournament, { action: default_update_action, 
                                location: @tournament.next_user_tournament_path })
  end

  def destroy
    @tournament.destroy
    respond_with(@tournament, location: user_tournaments_path)
  end

  def prize_pool

  end

  def users
    @collaborators = @tournament.collaborators
    @invites = @tournament.invites
  end

  private

  def default_update_action
    if update_params[:prizepool].present?
      :prize_pool
    else
      :edit
    end
  end

  def create_params
    params[:tournament]
  end

  def update_params
    params[:tournament]
  end

  def ensure_tournament
    @tournament = Tournament.find params[:id]
  end

  def ensure_tournament_prizepool_required
    unless @tournament.prizepool_required?
      message = 'Unable to add a payment to that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_tournament_editable_by_user
    unless @tournament.editable_by_user?(current_user)
      message = 'You do not have permission to edit that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

  def ensure_tournament_destroyable_by_user
    unless @tournament.destroyable_by_user?(current_user)
      message = 'You do not have permission to destroy that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

end
