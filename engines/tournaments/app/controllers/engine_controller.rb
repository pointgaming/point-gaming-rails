class EngineController < ApplicationController
  include Rails.application.routes.url_helpers
  before_filter :authenticate_user!

  protected

  def ensure_tournament
    @tournament = Tournament.find_by(slug: params[:tournament_id] || params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    message = "The tournament was not found"
    respond_with({errors: [message]}, status: 404) do |format|
      format.html { redirect_to tournaments_path, alert: message }
    end
  end

  def ensure_tournament_started
    @tournament = Tournament.find_by(slug: params[:tournament_id] || params[:id])
    unless @tournament.started?
      message = "The tournament has not started yet"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to @tournament, alert: message }
      end
    end
  end

  def ensure_tournament_owner
    unless @tournament.owner._id === current_user._id
      message = "You do not have permission to edit that tournaments collaborators"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

  def ensure_tournament_prizepool_required
    unless @tournament.prizepool_required?
      message = "Unable to add a payment to that tournament"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to @tournament, alert: message }
      end
    end
  end

  def ensure_tournament_editable_by_user
    unless current_user.can? :edit, @tournament
      message = "You do not have permission to edit that tournament"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to tournaments_path, alert: message }
      end
    end
  end

  def next_tournament_path
    if @tournament.prizepool_required?
      prize_pool_tournament_path(@tournament)
    elsif @tournament.payment_required?
      new_tournament_payment_path(@tournament)
    elsif @tournament.payment_pending?
      status_tournament_path(@tournament)
    elsif @tournament.activated?
      users_tournament_path(@tournament)
    end
  end
end
