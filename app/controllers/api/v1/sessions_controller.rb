class Api::V1::SessionsController < ApplicationController
  before_filter :authenticate_user!, :except=>[:create]
  before_filter :ensure_params_exist, :only=>[:create]
  before_filter :ensure_auth_token, :only=>[:destroy]

  respond_to :json

  def create
    resource = User.find_for_database_authentication(:username => params[:username])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      sign_in :user, resource
      @auth_token = resource.auth_tokens.build
      if @auth_token.save
        render :json => {
          :success=>true,
          :auth_token=>@auth_token._id,
          :username=>resource.username
        }
      else
        render :json => {:success=>false, :message=>"Failed to create the auth_token"}, :status=>500
      end
    else
      invalid_login_attempt
    end
  end

  def show
    render :json => {:success=>true, username: current_user.username}
  end

  def update
    if params[:status].nil?
      render :json => {:success=>false, :message=>"Missing status parameter"}, :status=>422
      return
    end

    if current_user.update_attributes(:status => params[:status])
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to update the user status", :errors=>current_user.errors}
    end
  end

  def destroy
    if @auth_token.destroy
      sign_out :user
      render :json => {:success=>true}
    else
      render :json => {:success=>false, :message=>"Failed to delete the auth_token"}
    end
  end

  protected

  def ensure_params_exist
    return unless params[:username].blank? || params[:password].blank?
    render :json => {:success=>false, :message=>"Missing username or password parameter"}, :status=>422
  end

  def ensure_auth_token
    begin
      @auth_token = AuthToken.find params[:auth_token]
    rescue Mongoid::Errors::DocumentNotFound
      render :json => {:success=>false, :message=>"Failed to retrieve auth_token"}, :status=>401
    end
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json => {:success=>false, :message=>"Invalid username or password"}, :status=>401
  end
end
