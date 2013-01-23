class Api::V1::IgnoresController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, :only=>[:create, :destroy]
  before_filter :ensure_user, :only=>[:create, :destroy]
  before_filter :ensure_ignore, :only=>[:destroy]

  respond_to :json

  def index
    begin
      @ignores = Ignore.where(user_id: current_user._id).all
      @ignores = @ignores.map { |ignore| ignore.ignore_user }
      render :json => {:success=>true, :ignores=>@ignores}
    rescue
      render :json => {:success=>true, :ignores=>[]}
    end
  end

  def create
    @ignore = Ignore.create({user_id: current_user._id, ignore_user_id: @user._id})
    if @ignore.save
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to add the user to the ignore list", :errors=>@ignore.errors}, :status=>500
    end
  end

  def destroy
    if @ignore.destroy
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to remove the user from the ignore list", :errors=>@ignore.errors}, :status=>500
    end
  end

  protected

  def ensure_params_exist
    return unless params[:user].blank?
    render :json => {:success=>false, :message=>"Missing user parameter"}, :status=>422
  end

  def ensure_user
    begin
      @user = User.find_by(username: params[:user][:username])
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"User not found"}, :status=>404
    end
  end

  def ensure_ignore
    begin
      @ignore = Ignore.find_by(user_id: current_user._id, ignore_user_id: @user._id)
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"You are not ignoring that user"}, :status=>404
    end
  end
end
