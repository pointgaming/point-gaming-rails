class Admin::ReportsController < Admin::ApplicationController
  respond_to :html, :json

  def sub_layout
    "admin" if action_name === 'index'
  end

  def index
    respond_with(nil)
  end

  def point_audit
    @number_of_pro_subscriptions = Order.count
    @expected_total_points = PointTransaction.sum(:amount)
    @current_total_points = User.sum(:points)
  end

end
