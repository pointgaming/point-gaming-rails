class BetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_stream
  before_filter :ensure_bet, except: [:new, :create]
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_not_bet_owner, only: [:update]
  before_filter :ensure_bet_owner, only: [:destroy]
  before_filter :ensure_no_bettor, only: [:update, :destroy]

  def new
    @bet = Bet.new({stream_id: @stream.id, map: @stream.map})
  end

  def show

  end

  def create
    @bet = Bet.new(params[:bet].merge({stream_id: @stream.id, bookie_id: current_user.id, map: @stream.map}))

    respond_to do |format|
      if @bet.save
        format.html { redirect_to stream_path(@stream), notice: 'Bet was created successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to stream_path(@stream), alert: 'Failed to create the bet.' }
        format.json { render json: @bet.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @bet.bettor = current_user

    respond_to do |format|
      if @bet.save
        format.html { redirect_to stream_path(@stream), notice: 'Bet was accepted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to stream_path(@stream), alert: 'Failed to accept the bet.' }
        format.json { render json: @bet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bet.destroy

    respond_to do |format|
      format.html { redirect_to stream_url(@stream) }
      format.json { head :no_content }
    end
  end

protected

  def ensure_stream
    @stream = Stream.find(params[:user_stream_id])
  end

  def ensure_stream_owner
    @stream_owner = @stream.owner
    unless @stream_owner.try(:user_id) === current_user.id
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: 'You do not have permission to make changes to that stream.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_params
    if params[:bet].blank?
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: 'Invalid or missing parameters.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:bet][:username]).first
    unless @user
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: "The specified user was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_bet
    @bet = Bet.where(stream_id: @stream._id).find params[:id]
    unless @bet
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: "The specified bet was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_bet_owner
    unless @bet.bookie_id === current_user._id
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: 'You do not have permission to make changes to that bet.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_not_bet_owner
    unless @bet.bookie_id != current_user._id
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: 'You do not have permission to accept the bet because you are the bet owner.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_no_bettor
    unless @bet.bettor.nil?
      respond_to do |format|
        format.html { redirect_to stream_path(@stream), alert: 'You cannot make that change to the bet because the bet has been accepted by another user.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
