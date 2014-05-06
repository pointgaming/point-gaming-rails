class EngineController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to @tournament ? @tournament : tournaments_path, alert: exception.message
  end

  protected

  def ensure_tournament_started
    raise CanCan::AccessDenied.new("The tournament has not started yet") unless @tournament.started?
  end

  def ensure_tournament_owner
    raise CanCan::AccessDenied.new("You do not own this tournament.") unless @tournament.owner == current_user
  end

  def ensure_tournament_editable_by_user
    authorize! :crud, @tournament
  end
end
