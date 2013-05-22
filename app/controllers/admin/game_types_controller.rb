class Admin::GameTypesController < Admin::ApplicationController
  before_filter :lookup_game, only: [:index]
  before_filter :ensure_game, only: [:new, :create]
  before_filter :ensure_game_type, except: [:index, :new, :create]
  authorize_resource

  respond_to :html, :json

  def sub_layout
    "admin"
  end

  def index
    @games = Game.all
  end

  def new
    @game_type = GameType.new(game: @game)
    respond_with(@game_type)
  end

  def edit
    respond_with(@game_type)
  end

  def create
    @game_type = GameType.new(params[:game_type].merge(game: @game))
    @game_type.save
    respond_with(@game_type, location: admin_game_types_path(game_id: params[:game_id]))
  end

  def update
    @game_type.update_attributes(params[:game_type])
    respond_with(@game_type, location: admin_game_types_path(game_id: @game_type.game_id))
  end

  def destroy
    @game_type.destroy
    respond_with(@game_type, location: admin_game_types_path(game_id: @game_type.game_id))
  end

protected

  def ensure_game_type
    @game_type = GameType.find params[:id]
  end

  def lookup_game
    @game = Game.find(params[:game_id]) if params[:game_id].present?
  end

  def ensure_game
    @game = Game.find(params[:game_id])
  end
end
