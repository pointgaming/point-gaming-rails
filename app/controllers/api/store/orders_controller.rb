module Api
  module Store
    class OrdersController < Api::ApplicationController
      before_filter :authenticate_store_api!

      respond_to :json

      def log
        order = ::Store::Order.find(params[:id])
        user = ::User.find_by(slug: params[:slug])

        ::UserOrderLoggerService.new(user: user, order: order).log
        ::OrderPointKickbackProcessorService.new(user: user, order: order).process

        render json: { success: true }
      end

    end
  end
end
