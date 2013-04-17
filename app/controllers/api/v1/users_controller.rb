class Api::V1::UsersController < Api::ApplicationController
  before_filter :authenticate_rails_app_api!

  def show
    @user = User.find_by(slug: params[:id])
    render json: {user: @user.as_json({ include: [:group], except: [:password] })}
  rescue
    render json: {}, status: 404
  end

end
