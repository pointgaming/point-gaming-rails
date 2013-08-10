module Api
  module Friends
    class ContextController < Api::ApplicationController
      before_filter :authenticate_user!

      respond_to :json

      protected

        def ensure_friends
          @friends = Friend.where(user_id: current_user._id).all
          @friends = @friends.map { |friend| friend.friend_user }
        rescue
          @friends = []
        end
    end
  end
end