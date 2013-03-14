class BetHistoryController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_bet, only: [:show]

  def sub_layout
    "settings"
  end

  def index
    @bets = Bet.for_user(current_user).order_by(created_at: 'DESC').all
  end

  def show
    
  end

private

  def ensure_bet
    @bet = Bet.for_user(current_user).find params[:id]
  end
end
