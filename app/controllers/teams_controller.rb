class TeamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_team, except: [:index, :new, :create]

  def sub_layout
    "settings"
  end

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

  def destroy
    @team.destroy

    redirect_to teams_path
  end

protected

  def ensure_team
    @team = Team.find params[:id]
  end
end
