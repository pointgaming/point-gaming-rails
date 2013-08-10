module Api
  module Friends
    class FriendsController < Api::Friends::ContextController
      before_filter :ensure_friends, only: [:index]

      def index
        respond_with(@friends)
      end

      def destroy
        begin
          @friend = Friend.find_by(user_id: current_user._id, friend_user_id: params[:id])
          @friend2 = Friend.where(user_id: @friend.friend_user_id, friend_user_id: current_user._id)
        rescue Mongoid::Errors::DocumentNotFound
          render :json => {:success=>false, :message=>"Invalid friend id"}, :status=>404
          return
        end

        if @friend.destroy && @friend2.destroy
          render :json => {:success=>true}
        else
          render :json => {:success=>false, :message=>"Failed to delete the friend relation", :errors=>[@friend.errors,@friend2.errors]}, :status=>500
        end
      end
    end
  end
end