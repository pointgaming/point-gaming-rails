class OrderActions
  include PointGamingRailsUrlHelper

  attr_accessor :user, :order

  def initialize(user, order)
    @user = user
    @order = order
  end

  def actions
    actions = {}
    actions[:View] = order_url(order)
    actions
  end

end
