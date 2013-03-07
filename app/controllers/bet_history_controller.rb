class BetHistoryController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_bet, only: [:show]

  def sub_layout
    "settings"
  end

  def index
    @bets = Bet.any_of({bettor_id: current_user._id}, {bookie_id: current_user._id}).all
  end

  def show
    
  end

private

  def ensure_bet
    @bet = Bet.any_of({bettor_id: current_user._id}, {bookie_id: current_user._id}).find params[:id]
  end
end
