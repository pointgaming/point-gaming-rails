module Api
  module Coins
    class ContextController < Api::ApplicationController
      before_filter :authenticate_user!

      respond_to :json

      protected

        def ensure_params_exist
          return unless params[:coin].blank?
          render :json => {:success=>false, :message=>"Missing coin parameter"}, :status=>422
        end

        def ensure_coin
          begin
            @coin = Coin.where(user_id: current_user._id).find(params[:id])
          rescue Mongoid::Errors::DocumentNotFound
            render :json => {:success=>false, :message=>"That coin was not found"}, :status=>404
          end
        end
    end
  end
end