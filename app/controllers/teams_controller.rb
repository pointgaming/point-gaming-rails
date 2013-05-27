class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_team, except: [:index, :new, :create, :change_active]
  before_filter :lookup_team_member, only: [:show, :edit, :update]
  before_filter :ensure_change_active_params, only: [:change_active]
  before_filter :ensure_params, only: [:update]
  before_filter :ensure_user_is_team_member, only: [:change_active]
  before_filter :ensure_edit_team_permission, only: [:edit, :update]

  respond_to :html, :json

  def index
    @team_members = TeamMember.where(user_id: current_user.id).all
    respond_with(@team_members)
  end

  def new
    @team = Team.new
    respond_with(@team)
  end

  def show
    respond_with(@team)
  end

  def edit
    respond_with(@team)
  end

  def update
    @team.update_attributes(update_params)
    respond_with(@team, location: edit_team_path(@team))
  end

  def create
    @team = Team.new(params[:team])
    member = @team.members.build({team_id: @team._id, user_id: current_user.id, rank: 'Leader'})

    if @team.save && member.save
      redirect_to teams_path
    else
      render :action => :new
    end
  end

  def change_active
    current_user.team = params[:user][:team_id].blank? ? nil : @team_member.team;
    if current_user.save
      redirect_to teams_path, notice: 'Your active team was changed successfully.'
    else
      redirect_to teams_path, alert: 'Failed to change your active team.'
    end
  end

  def destroy
    @team.destroy

    redirect_to teams_path
  end

protected

  def ensure_team
    @team = Team.where(slug: params[:id]).first
    raise Mongoid::Errors::DocumentNotFound unless @team.present?
  end

  def ensure_change_active_params
    unless params[:user].try(:[], :team_id)
      redirect_to teams_path, alert: 'Invalid params.'
    end
  end

  def ensure_user_is_team_member
    unless params[:user][:team_id].blank?
      @team_member = TeamMember.where(user_id: current_user._id, team_id: params[:user][:team_id]).first
      redirect_to teams_path, alert: 'Invalid team specified.' if @team_member.nil?
    end
  end

  def ensure_params
    unless params[:team].present?
      respond_with({errors: ['Missing team param']}, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing team param' }
      end
    end
  end

  def update_params
    params[:team].slice(:logo)
  end

  def lookup_team_member
    @member = TeamMember.where(user_id: current_user._id, team_id: @team._id).first
  end

  def ensure_edit_team_permission
    unless @member.can_edit_team?
      respond_with(nil, status: 403) do |format|
        format.html { redirect_to :back, alert: 'You do not have permission to do that' }
      end
    end
  end

end
