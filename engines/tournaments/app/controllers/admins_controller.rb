class AdminsController < EngineController
  load_resource :tournament, find_by: :slug
  before_filter :ensure_tournament_owner

  def create
    user = User.where(username: params[:admin][:username]).first

    if user && user.can?(:administer, @tournament)
      @tournament.admins << user.id and @tournament.save
      flash.notice = "#{user} is now a tournament admin."
    else
      flash.alert = "#{user} is not a valid tournament admin."
    end

    redirect_to edit_tournament_path(@tournament, anchor: "users")
  end

  def destroy
    @tournament.admins.delete_if { |c| c == params[:id] } and @tournament.save
    flash.notice = "Admin successfully removed."
    redirect_to edit_tournament_path(@tournament, anchor: "users")
  end
end
