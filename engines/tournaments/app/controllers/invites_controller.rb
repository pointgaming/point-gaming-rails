class InvitesController < EngineController
  before_filter :ensure_tournament
  before_filter :ensure_tournament_editable_by_user

  def create
    user = User.where(username: params[:invite][:username]).first
    if user && user.can?(:be_invited, @tournament)
      @tournament.invites << user.id and @tournament.save
      flash.notice = "#{user} successfully invited!"
    else
      flash.alert = "#{user} cannot be invited."
    end

    redirect_to edit_tournament_path(@tournament, anchor: "users")
  end

  def destroy
    @tournament.invites.delete_if { |i| i == params[:id] } and @tournament.save
    flash.notice = "Invite successfully revoked."
    redirect_to edit_tournament_path(@tournament, anchor: "users")
  end
end
