class UserAccountBalanceController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_user_is_current_user

  respond_to :html, :json

  def index
    @transaction_history = @user.transaction_history.order_by(created_at: :desc)
    @user_subscription = @user.subscriptions.active.first
  end

  private

  def ensure_user
    @user = User.find_by(slug: params[:user_id])
  end

  def ensure_user_is_current_user
    unless @user == current_user
      message = 'You cannot view that users account balance'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_profile_path(@user), alert: message }
      end
    end
  end

end
