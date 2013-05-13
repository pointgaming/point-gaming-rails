class DisputeMessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_dispute
  before_filter :ensure_user_can_view_dispute
  before_filter :ensure_params_exist, :only=>[:create]

  respond_to :html, :json

  def new
    @dispute_message = DisputeMessage.new({user_id: current_user._id, dispute: @dispute})
    respond_with(@dispute_message)
  end

  def create
    @dispute_message = DisputeMessage.new(params[:message].merge!({user_id: current_user._id, dispute: @dispute}))
    @dispute_message.save
    respond_with(@dispute_message, location: dispute_url(@dispute, anchor: "message-#{@dispute_message._id}"))
  end

protected

  def ensure_params_exist
    if params[:message].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to new_dispute_message_path(@dispute), alert: 'Missing dispute parameter' }
      end
    end
  end

  def ensure_dispute
    @dispute = Dispute.find(params[:dispute_id])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(nil, status: 404) do |format|
      format.html { redirect_to dispute_messages_path, alert: 'The dispute was not found' }
    end
  end

  def ensure_user_can_view_dispute
    unless Bet.for_user(current_user).for_match(@dispute.match).length > 0
      respond_with(nil, status: 404) do |format|
        format.html { redirect_to disputes_path, alert: 'The dispute was not found' }
      end
    end
  end

end
