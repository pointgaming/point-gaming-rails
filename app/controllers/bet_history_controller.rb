class BetHistoryController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_bet, only: [:show]

  def show
    
  end

  private

  def ensure_bet
    @bet = Bet.for_user(current_user).find params[:id]
  end

end
