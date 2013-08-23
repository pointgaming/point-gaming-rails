class Api::V1::UsersController < Api::ApplicationController
  before_filter :authenticate_user_or_api_call!
  before_filter :ensure_params, only: [:index]
  before_filter :ensure_user, only: [:show]

  respond_to :json

  def index
    @users = User.in(_id: params[:user_id]).all
    respond_with(@users)
  end

  def show
    render json: { user: @user.as_json({ include: [:group], except: [:password] }) }
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

end
