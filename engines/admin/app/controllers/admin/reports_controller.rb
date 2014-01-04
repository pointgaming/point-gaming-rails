module Admin
  class ReportsController < Admin::ApplicationController
    respond_to :html, :json

    def index
      respond_with(nil)
    end

    def point_audit
      @number_of_pro_subscriptions = Order.count
      @expected_total_points = UserPointHistory.where(affected_total_system_points: true).sum(:amount)
      @current_total_points = User.sum(:points)
    end
  end
end
