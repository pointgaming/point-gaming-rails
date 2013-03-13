class UserStreamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_stream, except: [:index, :new, :create]
  before_filter :ensure_stream_owner, only: [:change_owner, :start, :stop, :destroy]
  before_filter :ensure_owner_params, only: [:change_owner]
  before_filter :ensure_collaborator, only: [:change_owner]
  before_filter :enforce_stream_limit_current_user, only: [:create]
  before_filter :enforce_stream_limit_collaborator, only: [:change_owner]

  def index
    @streams = Collaborator.where(user_id: current_user.id).all.collect {|c| c.stream}
  end

  def new
    @stream = Stream.new
  end

  def show
    @collaborators = Collaborator.where(stream_id: @stream.id).all
  end

  def edit

  end

  def create
    @stream = Stream.new(params[:stream])
    collaborator = @stream.collaborators.build({stream_id: @stream.id, user_id: current_user.id, owner: true})

    respond_to do |format|
      if @stream.save && collaborator.save
        format.html { redirect_to user_streams_path, notice: 'The stream was created successfully.' }
        format.json { render json: @stream, status: :created, location: user_stream_path(@stream) }
      else
        format.html { render action: "new" }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @stream.update_attributes(params[:stream])
        format.html { redirect_to user_stream_path(@stream), notice: 'The stream was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_owner
    current_owner = @stream.owner
    current_owner.owner = false

    @collaborator.owner = true

    respond_to do |format|
      if current_owner.id === @collaborator.id || (current_owner.save && @collaborator.save)
        format.html { redirect_to user_stream_path(@stream), notice: 'The stream owner was changed successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to user_stream_path(@stream), alert: 'Failed to change the stream owner.' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def start
    respond_to do |format|
      if @stream.update_attributes({streaming: true})
        format.html { redirect_to user_stream_path(@stream), notice: 'The stream was started successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to user_stream_path(@stream), alert: 'Failed to start the stream.' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def stop
    respond_to do |format|
      if @stream.update_attributes({streaming: false})
        format.html { redirect_to user_stream_path(@stream), notice: 'The stream was stopped successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to user_stream_path(@stream), alert: 'Failed to stop the stream.' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @stream.destroy

    respond_to do |format|
      format.html { redirect_to user_streams_url }
      format.json { head :no_content }
    end
  end

protected

  def ensure_stream
    @stream = Stream.find(params[:id])
    @stream_owner = @stream.owner
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

  def ensure_owner_params
    return unless params[:collaborator].blank? || params[:collaborator][:id].blank?
    respond_to do |format|
      format.html { redirect_to user_stream_path(@stream), alert: 'Failed to change owner. Invalid or missing parameters.' }
      format.json { render json: [], status: :unprocessable_entity }
    end
  end

  def ensure_collaborator
    @collaborator = Collaborator.where(stream_id: @stream.id).find params[:collaborator][:id]
    unless @collaborator
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: "Failed to change owner. Invalid collaborator specified." }
        format.json { render json: [], status: :unprocessable_entity }
      end
    end
  end

  def enforce_stream_limit_current_user
    if current_user.stream_owner_count >= current_user.stream_limit
      message = "You have reached the maximum number of streams."
      respond_to do |format|
        format.html { redirect_to user_streams_path, alert: message }
        format.json { render json: [message], status: :unprocessable_entity }
      end
    end
  end

  def enforce_stream_limit_collaborator
    if @collaborator.blank? || @collaborator.user.stream_owner_count >= @collaborator.user.stream_limit
      message = "Unable to set the new stream owner because the user has reached the maximum number of streams."
      respond_to do |format|
        format.html { redirect_to user_stream_path(@stream), alert: message }
        format.json { render json: [message], status: :unprocessable_entity }
      end
    end
  end

end
