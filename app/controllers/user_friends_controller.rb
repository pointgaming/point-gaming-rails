class UserFriendsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user

  def index
    @friends = @user.friends
  end

private

  def ensure_user
    @user = User.find_by(slug: params[:user_id])
  end

end
