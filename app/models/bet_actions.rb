class BetActions
  include PointGamingRailsUrlHelper

  attr_accessor :user, :bet

  def initialize(user, bet)
    @user = user
    @bet = bet
  end

  def actions
    actions = {}
    actions[:View] = bet_url(bet)
    actions
  end

end
