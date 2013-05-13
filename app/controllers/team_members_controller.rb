class TeamMembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_team
  before_filter :ensure_team_owner
  before_filter :ensure_create_params, only: [:create]
  before_filter :ensure_user, only: [:create]
  before_filter :ensure_user_not_member, :only=>[:create]
  before_filter :ensure_team_member, only: [:edit, :update, :destroy]

  def new
    @team_member = TeamMember.new
  end

  def edit

  end

  def create
    @team_member = TeamMember.new({team_id: @team.id, user_id: @user.id, rank: params[:team_member][:rank]})

    respond_to do |format|
      if @team_member.save
        format.html { redirect_to team_path(@team), notice: 'Member was added successfully.' }
        format.json { render json: true }
      else
        format.html { redirect_to team_path(@team), alert: 'Failed to add the user to the team.' }
        format.json { render json: @team_member.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @team_member.update_attributes(params[:team_member])
        format.html { redirect_to team_path(@team), notice: 'Member was updated successfully.' }
        format.json { render json: true }
      else
        format.html { redirect_to team_path(@team), alert: 'Failed to update the team member.' }
        format.json { render json: @team_member.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @team_member.destroy

    respond_to do |format|
      format.html { redirect_to team_url(@team) }
      format.json { render json: true }
    end
  end

protected

  def ensure_team
    @team = Team.where(slug: params[:team_id]).first
    raise Mongoid::Errors::DocumentNotFound unless @team.present?
  end

  def ensure_team_owner
    @member = TeamMember.where(user_id: current_user._id, team_id: @team._id).first
    unless @member.leader?
      respond_to do |format|
        format.html { redirect_to team_path(@team), alert: 'You do not have permission to add users to that team.' }
        format.json { render json: ['You do not have permission to add users to that team'], status: :unprocessable_entity }
      end
    end
  end

  def ensure_create_params
    if params[:user][:username].blank?
      respond_to do |format|
        format.html { redirect_to team_path(@team), alert: 'Invalid or missing parameters.' }
        format.json { render json: ["Username can't be blank"], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:user][:username]).first
    unless @user
      respond_to do |format|
        format.html { redirect_to team_path(@team), alert: "The specified user was not found." }
        format.json { render json: ['That user was not found'], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user_not_member
    @team_member = TeamMember.where(team_id: @team._id, user_id: @user._id).length
    if @team_member > 0
      respond_to do |format|
        format.html { redirect_to team_path(@team), alert: "That user is already a member of this team." }
        format.json { render json: ['That user is already a member of this team.'], status: :unprocessable_entity }
      end
    end
  end

  def ensure_team_member
    @team_member = TeamMember.where(team_id: @team._id).find params[:id]
    unless @team_member
      respond_to do |format|
        format.html { redirect_to team_path(@team), alert: "The member specified does not exist." }
        format.json { render json: ['That member does not exist'], status: :unprocessable_entity }
      end
    end
  end
end
