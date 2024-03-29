class DisputesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_match, :only=>[:new, :create]
  before_filter :ensure_user_can_dispute_match, only: [:new, :create]
  before_filter :ensure_params, :only=>[:create]
  before_filter :ensure_dispute, :only=>[:show, :cancel]
  before_filter :ensure_user_can_view_dispute, only: [:show]
  before_filter :ensure_dispute_owner, only: [:cancel]
  before_filter :ensure_can_cancel_dispute, only: [:cancel]

  respond_to :html, :json

  def index
    match_ids = current_user.bets.map(&:match_id).uniq
    @disputes = match_ids.length > 0 ? Dispute.in(match_id: match_ids).all : []
    respond_with(@disputes)
  end

  def new
    @dispute = Dispute.new({owner_id: current_user._id, match: @match})
    respond_with(@dispute)
  end

  def create
    @dispute = Dispute.new(create_params)
    @message = @dispute.messages.build(params[:message].merge!({user_id: current_user._id}))
    @dispute.save
    @message.save

    match_log = @dispute.match_logs.build({action: :create_dispute, modified: @dispute.attributes.dup})
    match_log.save

    respond_with(@message, location: @dispute)
  end

  def show
    @dispute_message = DisputeMessage.new(dispute_id: @dispute.id)
  end

  def cancel
    @dispute.cancel!
    respond_with(@dispute)
  end

protected

  def create_params
    params[:dispute].slice(:reason, :cheater_id).merge(owner_id: current_user._id, match: @match)
  end

  def ensure_params
    message = 'Missing dispute parameter' if params[:dispute].blank?
    message = 'Missing message parameter' if params[:message].blank?

    if message.present?
      respond_with({errors: [message]}, status: 422) do |format|
        format.html { redirect_to new_match_dispute_path(@match), alert: message }
      end
    end
  end

  def ensure_match
    @match = Match.find(params[:match_id])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(nil, status: 404) do |format|
      format.html { redirect_to disputes_path, alert: 'The match was not found' }
    end
  end

  def ensure_dispute
    @dispute = Dispute.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(nil, status: 404) do |format|
      format.html { redirect_to disputes_path, alert: 'The dispute was not found' }
    end
  end

  def ensure_user_can_dispute_match
    unless @match.is_disputable? && @match.can_be_disputed_by?(current_user)
      message = 'You do not have permission to dispute that match'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to disputes_path, alert: message }
      end
    end
  end

  def ensure_user_can_view_dispute
    unless @dispute.can_be_viewed_by?(current_user)
      message = 'That dispute was not found'
      respond_with({errors: [message]}, status: 404) do |format|
        format.html { redirect_to disputes_path, alert: message }
      end
    end
  end

  def ensure_dispute_owner
    unless @dispute.owner_id === current_user._id
      message = 'Permission Denied'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to disputes_path, alert: message }
      end
    end
  end

  def ensure_can_cancel_dispute
    raise ::PermissionDenied unless @dispute.can_cancel?
  end

end
