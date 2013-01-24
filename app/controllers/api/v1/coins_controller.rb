class Api::V1::CoinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create]
  before_filter :ensure_coin, :only=>[:show, :destroy]

  respond_to :json

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
