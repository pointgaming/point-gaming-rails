module Store
  class OrderActions
    include PointGamingRailsUrlHelper

    attr_accessor :user, :order

    def initialize(user, order)
      @user = user
      @order = order
    end

    def actions
      actions = {}
      actions[:View] = store_order_url(order)
      actions
    end

  end
end
