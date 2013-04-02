class Api::V1::UsersController < Api::ApplicationController
  before_filter :authenticate_rails_app_api!

  def show
    @user = User.find(params[:id])
    render json: {user: @user.as_json({ except: [:password] })}
  rescue
    render json: {}, status: 404
  end

end
