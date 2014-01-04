class UserPointService

  def initialize(user)
    @user = user
  end

  def create(amount, action_source)
    increment_user_points(@user, amount, action_source, true)
  end

  def destroy(amount, action_source)
    increment_user_points(@user, amount * -1, action_source, true)
  end

  def transfer(to_user, amount, action_source)
    decrement_amount = amount * -1
    increment_user_points(@user, decrement_amount, action_source, false)

    increment_user_points(to_user, amount, action_source, false)
  end

  private

  def increment_user_points(user, amount, action_source, affected_total_system_points)
    start_balance = user.points

    user.increment_points!(amount)
    user.reload

    UserPointHistory.create!({
      user: user,
      start_balance: start_balance,
      end_balance: user.points,
      amount: amount,
      action_source_id: action_source.id,
      action_source_type: action_source.class.name,
      description: UserPointHistoryDescription.new(action_source).to_s,
      affected_total_system_points: affected_total_system_points
    })
  end

end
