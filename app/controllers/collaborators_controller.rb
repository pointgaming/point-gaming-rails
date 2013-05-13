class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_stream
  before_filter :ensure_stream_owner
  before_filter :ensure_create_params, only: [:create]
  before_filter :ensure_user, only: [:create]
  before_filter :ensure_collaborator, only: [:destroy]

  def index
    @collaborators = Collaborator.where(stream_id: @stream._id).all
  end

  def new
    @collaborator = Collaborator.new
  end

  def create
    @collaborator = Collaborator.new({stream_id: @stream.id, user_id: @user.id})

    respond_to do |format|
      if @collaborator.save
        format.html { redirect_to user_stream_path(@stream), notice: 'Collaborator was added successfully.' }
        format.json { render json: true }
      else
        format.html { redirect_to user_stream_path(@stream), alert: 'Failed to add the user as a collaborator.' }
        format.json { render json: @collaborator.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @collaborator.destroy

    respond_to do |format|
      format.html { redirect_to user_stream_url(@stream) }
      format.json { render json: true }
    end
  end

protected

  def ensure_stream
    @stream = Stream.where(slug: params[:user_stream_id]).first
    raise Mongoid::Errors::DocumentNotFound unless @stream.present?
  end

  def ensure_stream_owner
    @stream_owner = @stream.owner
    unless @stream_owner.try(:user_id) === current_user.id
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: 'You do not have permission to make changes to that stream.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_create_params
    if params[:collaborator].blank? || params[:collaborator][:username].blank?
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: 'Invalid or missing parameters.' }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_user
    @user = User.where(username: params[:collaborator][:username]).first
    unless @user
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: "The specified user was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def ensure_collaborator
    @collaborator = Collaborator.where(stream_id: @stream._id).find params[:id]
    unless @collaborator
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: "The specified collaborator was not found." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end
end
