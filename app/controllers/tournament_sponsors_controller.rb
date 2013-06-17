class TournamentSponsorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_sponsor, only: [:edit, :update, :destroy]
  before_filter :ensure_params, only: [:create, :update]
  before_filter :ensure_tournament_editable

  respond_to :html, :json

  def new
    @sponsor = @tournament.sponsors.build
    respond_with(@sponsor)
  end

  def edit
    respond_with(@sponsor)
  end

  def create
    @sponsor = @tournament.sponsors.build(params[:tournament_sponsor])
    @sponsor.save
    respond_with(@sponsor, location: edit_user_tournament_path(@tournament))
  end

  def update
    @sponsor.update_attributes(params[:tournament_sponsor])
    respond_with(@sponsor, location: edit_user_tournament_path(@tournament))
  end

  def destroy
    @sponsor.destroy
    respond_with(@sponsor, location: edit_user_tournament_path(@tournament))
  end

protected

  def ensure_params
    if params[:tournament_sponsor].blank?
      message = 'Missing tournament_sponsor parameter'
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to :back, alert: message }
      end
    end
  end

  def ensure_tournament
    @tournament = Tournament.find params[:tournament_id]
  end

  def ensure_sponsor
    @sponsor = @tournament.sponsors.find params[:id]
  end

  def ensure_tournament_editable
    unless @tournament.editable_by_user?(current_user)
      message = 'You do not have permission to edit that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

end
