class UserPointsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_user_is_current_user

  respond_to :html, :json

  # I don't like that this controller action has 2 separate responsibilities...
  def index
    respond_to do |format|
      format.html do
        @point_history = @user.point_history.recent.order_by(created_at: :desc)
      end
      format.json do
        render json: UserPointGraph.new(@user)
      end
    end
  end

  private

  def ensure_user
    @user = User.find_by(slug: params[:user_id])
  end

  def ensure_user_is_current_user
    unless @user == current_user
      message = 'You cannot view that users points'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_profile_path(@user), alert: message }
      end
    end
  end

end
