class BetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_match
  before_filter :ensure_bet, except: [:new, :create]
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_not_bet_owner, only: [:update]
  before_filter :ensure_bet_owner, only: [:destroy]
  before_filter :ensure_no_taker, only: [:update, :destroy]

  respond_to :html, :json

  def new
    @bet = Bet.new({match: @match})
  end

  def show
    respond_with(@bet)
  end

  def create
    creator = BetCreatorService.new({
      params: params[:bet],
      match: @match,
      user: current_user
    })

    @bet = creator.bet

    creator.create
    respond_with(@match, @bet)
  end

  def update
    acceptor = BetAcceptorService.new({
      bet: @bet,
      user: current_user
    })

    acceptor.accept
    respond_with(@bet)
  end

  def destroy
    @bet.destroy
    respond_with(@bet)
  end

protected

  def ensure_match
    @match = Match.find params[:match_id]
    unless @match
      raise ::PermissionDenied
    end
  end

  def ensure_params
    if params[:bet].blank?
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@match), alert: 'Invalid or missing parameters.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_bet
    @bet = Bet.where(match: @match).find params[:id]
    unless @bet
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@match), alert: "The specified bet was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_bet_owner
    unless @bet.offerer_id === current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@match), alert: 'You do not have permission to make changes to that bet.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_not_bet_owner
    unless @bet.offerer_id != current_user._id
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@match), alert: 'You do not have permission to accept the bet because you are the bet owner.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_no_taker
    unless @bet.taker.nil?
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@match), alert: 'You cannot make that change to the bet because the bet has been accepted by another user.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
