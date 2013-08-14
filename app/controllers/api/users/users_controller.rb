module Api
  module Users
    class UsersController < Api::Users::ContextController
      before_filter :authenticate_user_or_api_call!, only: [:index, :show]
      before_filter :authenticate_rails_app_api!, only: [:increment_points_for_store_order]
      before_filter :ensure_params, only: [:index]
      before_filter :ensure_user, except: [:index]
      before_filter :ensure_store_order, only: [:increment_points_for_store_order]

      def index
        @users = User.in(_id: params[:user_id]).all
        respond_with :api, @users
      end

      def show
        render json: { user: @user.as_json({ include: [:group], except: [:password] }) }
      end

      def increment_points_for_store_order
        UserPointService.new(@user).create(params[:points].to_i, @store_order)
        render json: { success: true }
      end
    end
  end
end