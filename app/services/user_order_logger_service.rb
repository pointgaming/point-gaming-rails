class UserOrderLoggerService
  attr_reader :user, :order

  def initialize(opts)
    @user = opts.fetch(:user)
    @order = opts.fetch(:order)
    @log_model = opts[:log_model] || UserBillingHistory
  end

  def log
    @log_model.create({
      user: user,
      action_source_id: order.id,
      action_source_type: order.class.name,
      amount: order.total,
      description: order.description
    })
  end

end
