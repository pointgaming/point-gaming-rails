class Api::V1::BetsController < Api::ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_room
  before_filter :ensure_bet, except: [:new, :create]
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_offerer_choice, only: [:create]
  before_filter :ensure_taker_choice, only: [:create]
  before_filter :ensure_not_bet_owner, only: [:update]
  before_filter :ensure_bet_owner, only: [:destroy]
  before_filter :ensure_no_taker, only: [:update, :destroy]

  respond_to :json

  def new
    @bet = Bet.new({room: @room})
  end

  def show
    respond_with(@bet)
  end

  def create
    @bet = Bet.new(params[:bet])
    @bet.offerer = current_user
    @bet.room = @room
    @bet.offerer_odds = @match.default_offerer_odds if @match.room_type === 'GameRoom'

    @bet.offerer_choice = @offerer_choice
    @bet.offerer_choice_name = @offerer_choice.try(:display_name)

    @bet.taker_choice = @taker_choice
    @bet.taker_choice_name = @taker_choice.try(:display_name)

    @bet.save
    respond_with(@room, @bet)
  end

  def update
    @bet.taker = current_user

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

  def ensure_offerer_choice
    if ['player_1', 'player_2'].include?(params[:bet][:offerer_choice])
      @offerer_choice = @room.send(params[:bet][:offerer_choice])
    else
      nil
    end
  end

  def ensure_taker_choice
    if ['player_1', 'player_2'].include?(params[:bet][:taker_choice])
      @taker_choice = @room.send(params[:bet][:taker_choice])
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
    unless @bet.offerer_id === current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You do not have permission to make changes to that bet.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_not_bet_owner
    unless @bet.offerer_id != current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You do not have permission to accept the bet because you are the bet owner.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_no_taker
    unless @bet.taker.nil?
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@room), alert: 'You cannot make that change to the bet because the bet has been accepted by another user.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
