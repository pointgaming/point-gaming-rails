class UserBetLoggerService
  attr_reader :user, :bet

  def initialize(opts)
    @user = opts.fetch(:user)
    @bet = opts.fetch(:bet)
    @log_model = opts[:log_model] || UserBetHistory
  end

  def log(amount, description)
    @log_model.create({
      user: user,
      action_source_id: bet.id,
      action_source_type: bet.class.name,
      amount: amount,
      description: description
    })
  end

end
