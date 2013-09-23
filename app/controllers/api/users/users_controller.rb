module Api
  module Users
    class UsersController < Api::Users::ContextController
      before_filter :authenticate_user_or_api_call!
      before_filter :ensure_params, only: [:index]
      before_filter :ensure_user, except: [:index]

      def index
        @users = User.in(_id: params[:user_id]).all
        respond_with :api, @users
      end

      def show
        render json: { user: @user.as_json({ include: [:group], except: [:password] }) }
      end
    end
  end
end
