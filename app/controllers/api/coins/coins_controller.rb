module Api
  module Coins
    class CoinsController < Api::Coins::ContextController
      before_filter :ensure_params_exist, only: [:create]
      before_filter :ensure_coin, only: [:show, :destroy]

      def index
        begin
          @coins = Coin.where(user_id: current_user._id).all
          render :json => {:success=>true, :coins=>@coins}
        rescue
          render :json => {:success=>true, :coins=>[]}
        end
      end

      def create
        @coin = Coin.create(params[:coin])
        @coin.user = current_user
        if @coin.save
          render :json => {:success=>true, :_id=>@coin._id}
        else
          render :json => {:success=>false, :message=>"Failed to save the coin", :errors=>@coin.errors}, :status=>500
        end
      end

      def show
        render :json => {:success=>true, :coin=>@coin}
      end

      def destroy
        if @coin.destroy
          render :json => {:success=>true}
        else
          render :json => {:success=>false, :message=>"Failed to delete the coin", :errors=>@coin.errors}, :status=>500
        end
      end
    end
  end
end