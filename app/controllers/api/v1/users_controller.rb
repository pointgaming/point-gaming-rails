class Api::V1::UsersController < Api::ApplicationController
  before_filter :authenticate_rails_app_api!
  before_filter :ensure_params, only: [:index]
  before_filter :ensure_user, except: [:index]
  before_filter :ensure_store_order, only: [:increment_points_for_store_order]

  respond_to :json

  def index
    @users = User.in(_id: params[:user_id]).all
    respond_with(@users)
  end

  def show
    render json: { user: @user.as_json({ include: [:group], except: [:password] }) }
  end

  def increment_points_for_store_order
    UserPointService.new(@user).create(params[:points].to_i, @store_order)
    render json: { success: true }
  end

  private

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
