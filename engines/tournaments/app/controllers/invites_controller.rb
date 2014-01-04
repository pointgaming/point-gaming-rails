class InvitesController < EngineController
  before_filter :ensure_tournament
  before_filter :ensure_tournament_editable_by_user
  before_filter :ensure_params, only: [:create]
  before_filter :ensure_user, only: [:create]

  respond_to :html, :json

  def create
    @invite = Invite.create({tournament_id: @tournament._id, user_id: @user._id})
    respond_with(@invite, location: users_tournament_path(@tournament))
  end

  def destroy
    @tournament.invites.find(params[:id]).destroy
    respond_with(@invite, location: users_tournament_path(@tournament))
  end

  protected

  def ensure_params
    if params[:invite].blank?
      message = "Missing invite parameter"
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to @tournament, alert: message }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:invite][:username]).first
    unless @user
      message = "The specified user was not found."
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to @tournament, alert: message }
      end
    end
  end
end
