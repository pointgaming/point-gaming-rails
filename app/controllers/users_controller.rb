class UsersController < ApplicationController
  before_filter :authenticate_user!

  def search
    @users = User.where(username: /#{Regexp.escape(params[:query])}/).page(params[:page])

    respond_to do |format|
        format.html { render action: :search }
        format.json { render json: @users }
    end
  end
end
