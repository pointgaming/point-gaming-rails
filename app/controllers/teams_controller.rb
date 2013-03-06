class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_team, except: [:index, :new, :create, :change_active]
  before_filter :ensure_change_active_params, only: [:change_active]
  before_filter :ensure_user_is_team_member, only: [:change_active]

  def index
    @team_members = TeamMember.where(user_id: current_user.id).all
  end

  def new
    @team = Team.new
  end

  def show
    @member = TeamMember.where(user_id: current_user._id, team_id: @team._id).first
  end

  def edit

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

  def update
    if @team.update_attributes(params[:team])
      redirect_to teams_path
    else
      render :action => :edit
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
    @team = Team.find params[:id]
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
end
