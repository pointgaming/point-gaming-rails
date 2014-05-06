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
    @tournament.check_in!(@player)
    respond_with(@player, location: @tournament)
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
