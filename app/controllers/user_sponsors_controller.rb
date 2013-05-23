class UserSponsorsController < ApplicationController
  ssl_allowed :new, :edit, :create, :update, :destroy
  before_filter :authenticate_user!
  before_filter :ensure_user
  before_filter :ensure_sponsor, only: [:edit, :update, :destroy]
  before_filter :ensure_params, only: [:create, :update]
  before_filter :ensure_user_id_is_current_user

  respond_to :html, :json

  def new
    @sponsor = current_user.sponsors.build
    respond_with(@sponsor)
  end

  def edit
    respond_with(@sponsor)
  end

  def create
    @sponsor = @user.sponsors.build(params[:user_sponsor])
    @sponsor.save
    respond_with(@sponsor, location: edit_user_profile_path(@user))
  end

  def update
    @sponsor.update_attributes(params[:user_sponsor])
    respond_with(@sponsor, location: edit_user_profile_path(@user))
  end

  def destroy
    @sponsor.destroy
    respond_with(@sponsor, location: edit_user_profile_path(@user))
  end

protected

  def ensure_params
    if params[:user_sponsor].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing user_sponsor parameter' }
      end
    end
  end

  def ensure_user
    @user = User.find_by slug: params[:user_id]
  end

  def ensure_sponsor
    @sponsor = current_user.sponsors.find params[:id]
  end

  def ensure_user_id_is_current_user
    unless params[:user_id] === current_user.slug
      raise ::PermissionDenied
    end
  end
end
