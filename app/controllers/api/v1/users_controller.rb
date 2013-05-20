class Api::V1::UsersController < Api::ApplicationController
  before_filter :authenticate_rails_app_api!
  before_filter :ensure_user

  def show
    render json: {user: @user.as_json({ include: [:group], except: [:password] })}
  rescue
    render json: {}, status: 404
  end

  def increment_points
    @user.increment_points!(params[:points].to_i)
    render json: {success: true}
  rescue
    render json: {success: false}, status: :unprocessable_entity
  end

protected

  def ensure_user
    if params[:slug].present?
      @user = User.find_by(slug: params[:slug])
    else
      @user = User.find(params[:id])
    end
  end

end
