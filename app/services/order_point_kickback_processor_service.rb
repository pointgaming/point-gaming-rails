class OrderPointKickbackProcessorService
  attr_reader :user, :order

  def initialize(opts)
    @user = opts.fetch(:user)
    @order = opts.fetch(:order)
  end

  def process
    if order.point_kickback_total > 0
      UserPointService.new(user).create(order.point_kickback_total, order)
    end
  end

end
