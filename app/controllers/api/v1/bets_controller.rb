class Api::V1::BetsController < Api::ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_room
  before_filter :ensure_bet, except: [:new, :create]
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_winner, only: [:create]
  before_filter :ensure_loser, only: [:create]
  before_filter :ensure_not_bet_owner, only: [:update]
  before_filter :ensure_bet_owner, only: [:destroy]
  before_filter :ensure_no_bettor, only: [:update, :destroy]

  respond_to :json

  def new
    @bet = Bet.new({room: @room, map: @room.map})
  end

  def show
    respond_with(@bet)
  end

  def create
    @bet = Bet.new(params[:bet])
    @bet.bookie = current_user
    @bet.room = @room
    @bet.map = @room.map

    @bet.winner = @winner
    @bet.winner_name = @winner.try(:display_name)

    @bet.loser = @loser
    @bet.loser_name = @loser.try(:display_name)

    @bet.save
    respond_with(@room, @bet)
  end

  def update
    @bet.bettor = current_user

    @bet.save
    respond_with(@bet)
  end

  def destroy
    @bet.destroy
    respond_with(@bet)
  end

protected

  def ensure_room
    [:room_id, :stream_id].each do |key|
      if params[key].present?
        @room = key.to_s.gsub(/_id$/, '').classify.constantize.find(params[key])
      end
    end
    unless @room
      raise ::PermissionDenied
    end
  end

  def ensure_params
    if params[:bet].blank?
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'Invalid or missing parameters.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_winner
    if ['player_1', 'player_2'].include?(params[:bet][:winner])
      @winner = @room.send(params[:bet][:winner])
    else
      nil
    end
  end

  def ensure_loser
    if ['player_1', 'player_2'].include?(params[:bet][:loser])
      @loser = @room.send(params[:bet][:loser])
    else
      nil
    end
  end

  def ensure_bet
    @bet = Bet.where(room: @room).find params[:id]
    unless @bet
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: "The specified bet was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_bet_owner
    unless @bet.bookie_id === current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You do not have permission to make changes to that bet.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_not_bet_owner
    unless @bet.bookie_id != current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You do not have permission to accept the bet because you are the bet owner.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_no_bettor
    unless @bet.bettor.nil?
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You cannot make that change to the bet because the bet has been accepted by another user.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
