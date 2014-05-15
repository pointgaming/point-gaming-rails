class RegistrationsController < EngineController
  load_resource :tournament, find_by: :slug
  before_filter :get_player, only: [:update, :destroy]

  def create
    authorize! :join, @tournament
    @player = @tournament.players.create(user: current_user)
    respond_with(@player, location: @tournament)
  end

  def update
    authorize! :manage, @player
    if can?(:crud, @tournament)
      @tournament.check_in!(@player)
      redirect_to edit_tournament_path(@tournament, anchor: "players")
    else
      @tournament.check_in!(@player) if @tournament.checkin_open?
      respond_with(@player, location: @tournament)
    end
  end

  def destroy
    authorize! :manage, @player
    @tournament.kick!(@player)
    respond_with(@player, location: @tournament)
  end

  private
  def get_player
    @player = @tournament.players.find(params[:id])
  end
end
