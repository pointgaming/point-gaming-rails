# TODO add permission checks
class TournamentStatusController < ApplicationController
  before_filter :ensure_tournament, except: [:index]

  respond_to :html, :json

  def show
    @tournament_status_steps = @tournament.status_steps
    respond_with(@tournament)
  end

  private

  def ensure_tournament
    @tournament = Tournament.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    message = 'The tournament was not found'
    respond_with({errors: [message]}, status: 404) do |format|
      format.html { redirect_to tournaments_path, alert: message }
    end
  end

end
