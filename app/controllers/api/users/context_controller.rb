module Api
  module Users
    class ContextController < Api::ApplicationController

      respond_to :json

      protected

        def ensure_user
          if params[:slug].present?
            @user = User.find_by(slug: params[:slug])
          else
            @user = User.find(params[:id])
          end
        end

        def ensure_params
          unless params[:user_id].present?
            respond_with({ errors: ["Missing user_id parameter"] }, status: 422)
          end
        end

        def ensure_store_order
          @store_order = Store::Order.find(params[:order_id].to_i)
        rescue
          render json: { success: false }, status: :unprocessable_entity
        end
    end
  end
end