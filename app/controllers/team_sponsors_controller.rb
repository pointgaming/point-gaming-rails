class TeamSponsorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_team
  before_filter :ensure_sponsor, only: [:edit, :update, :destroy]
  before_filter :ensure_params, only: [:create, :update]
  before_filter :lookup_team_member
  before_filter :ensure_edit_sponsor_permission

  respond_to :html, :json

  def new
    @sponsor = @team.sponsors.build
    respond_with(@sponsor)
  end

  def edit
    respond_with(@sponsor)
  end

  def create
    @sponsor = @team.sponsors.build(params[:team_sponsor])
    @sponsor.save
    respond_with(@sponsor, location: team_path(@team))
  end

  def update
    @sponsor.update_attributes(params[:team_sponsor])
    respond_with(@sponsor, location: team_path(@team))
  end

  def destroy
    @sponsor.destroy
    respond_with(@sponsor, location: team_path(@team))
  end

protected

  def ensure_params
    if params[:team_sponsor].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing team_sponsor parameter' }
      end
    end
  end

  def ensure_team
    @team = Team.find_by slug: params[:team_id]
  end

  def ensure_sponsor
    @sponsor = @team.sponsors.find params[:id]
  end

  def lookup_team_member
    @member = TeamMember.where(user_id: current_user._id, team_id: @team._id).first
  end

  def ensure_edit_sponsor_permission
    unless @member.can_edit_team?
      respond_with({errors: ['You do not have permission to do that']}, status: 403) do |format|
        format.html { redirect_to :back, alert: 'You do not have permission to do that' }
      end
    end
  end

end
