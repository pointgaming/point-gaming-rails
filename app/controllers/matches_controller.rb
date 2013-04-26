class MatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_room, only: [:index, :new, :create]
  before_filter :load_games, only: [:new, :create, :show, :edit, :update]
  before_filter :ensure_match, except: [:index, :new, :create]
  before_filter :ensure_room_has_no_match, only: [:new, :create]
  before_filter :ensure_room_controller, except: [:index, :show]
  before_filter :ensure_player_or_team, only: [:create]

  respond_to :html, :json

  def index
    @matches = Match.order_by(:updated_at => 'DESC').where(room: @room).page(params[:page])
    respond_with(@matches)
  end

  def new
    @match = Match.new
    @match.game = Match.order_by(:created_at => 'DESC').where(room: @room).nin(game_id: nil).first.try(:game)
    respond_with(@match)
  end

  def show
    @match = Match.find params[:id]
    respond_with(@match)
  end

  def edit

  end

  def create
    @match = Match.new(params[:match].merge({room: @room}))
    @room.match = @match

    @match.save && @room.save
    respond_with(@match, location: [@room, @match])
  end

  def update
    if @match.state === 'new'
      update_match_attributes
    else
      update_match_winner
    end
  end

  def start
    @match.start!
    respond_with(@match)
  end

  def cancel
    @match.cancel!
    respond_with(@match)
  end

protected

  def update_match_attributes
    @match.update_attributes params[:match] if params[:match]
    respond_with(@match)
  end

  def update_match_winner
    if ['team', 'user'].include?(params[:match][:winner_type].downcase)
      winner = params[:match][:winner_type].classify.constantize.find(params[:match][:winner_id])
      @match.winner = winner
    end

    @match.save && @match.finalize!
    respond_with(@match)
  end

  def ensure_match
    @match = Match.find params[:id]
    @room = @match.room
  end

  def ensure_room
    if params[:stream_id].present?
      @room = Stream.where(slug: params[:stream_id]).first
    elsif params[:game_room_id].present?
      @room = GameRoom.find(params[:game_room_id])
    end
    unless @room
      raise ::PermissionDenied
    end
  end

  def load_games
    @games = Game.all
  end

  def ensure_room_has_no_match
    unless @room.match.blank?
      # TODO: handle this better
      raise ::PermissionDenied
    end
  end

  def ensure_room_controller
    if @room.class.eql?(Stream)

    elsif @room.class.eql?(GameRoom)

    else
      # TODO: handle this better
#      raise ::PermissionDenied
    end
  end

  def ensure_collaborator
    @collaborator = Collaborator.where(stream_id: @stream.id).find params[:collaborator][:id]
    unless @collaborator
      respond_to do |format|
        format.html { redirect_to match_path(@stream), alert: "Failed to change owner. Invalid collaborator specified." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_player_or_team
    begin
      [:player_1, :player_2].each do |player|
        if params[:match]["#{player}_id"].present? && ['user', 'team'].include?(params[:match]["#{player}_type"].downcase)
          # mongoid should throw an exception if this is not found
          record = params[:match]["#{player}_type"].constantize.find params[:match]["#{player}_id"]
          instance_variable_set "@#{player}".to_sym, record
        else
          raise "invalid_player"
        end
      end
    rescue
        message = 'An invalid player or team was specified'
        respond_to do |format|
          format.html { flash[:alert] = message ; render action: :new }
          format.json { render json: [message], status: :unprocessable_entity }
        end
    end
  end
end
