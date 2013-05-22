class UserProfilesController < ApplicationController
  ssl_required :edit, :update
  ssl_allowed :subregion_options
  before_filter :authenticate_user!, except: [:subregion_options]
  before_filter :ensure_user, except: [:subregion_options]
  before_filter :ensure_user_profile, except: [:subregion_options]
  before_filter :ensure_friends, except: [:subregion_options]
  before_filter :ensure_user_id_is_current_user, only: [:edit, :update]
  before_filter :lookup_game, only: [:update]

  respond_to :html, :json

  def show
    @matches = []
  end

  def edit

  end

  def update
    params[:user].delete("username")
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    params[:user][:game] = @game

    @user.update_attributes(params[:user])

    respond_with(@user)
  end

  def subregion_options
    render partial: 'subregion_select'
  end

protected

  def ensure_user
    @user = User.where(slug: params[:user_id]).first
    raise Mongoid::Errors::DocumentNotFound unless @user.present?
  end

  def ensure_user_profile
    unless @user.profile
      @user.build_profile.save
      @user.save
    end
    unless @user.profile.rig
      @user.profile.build_rig
    end
  end

  def ensure_friends
    @friends = Friend.where(user_id: @user._id).all.map { |friend| friend.friend_user }
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user.slug
      raise ::PermissionDenied
    end
  end

  def lookup_game
    @game = Game.find params[:user][:game_id] if params[:user][:game_id].present?
  rescue Mongoid::Errors::DocumentNotFound
    # @game is not required; no big deal
  end

end
