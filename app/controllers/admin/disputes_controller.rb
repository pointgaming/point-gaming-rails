class Admin::DisputesController < Admin::ApplicationController
  before_filter :ensure_dispute, except: [:index]
  before_filter :ensure_can_finalize_dispute, only: [:edit, :update]
  before_filter :ensure_can_cancel_dispute, only: [:cancel]

  respond_to :html, :json

  def index
    @disputes = Dispute.order_by(updated_at: :desc).all
    respond_with(@disputes)
  end

  def show
    @dispute_message = DisputeMessage.new(dispute_id: @dispute.id)
    respond_with(@dispute_message)
  end

  def edit
    respond_with(@dispute)
  end

  def update
    @dispute.finalize! if @dispute.update_attributes(update_params)
    respond_with(@dispute, location: admin_disputes_path)
  end

  def cancel
    @dispute.cancel!
    respond_with(@dispute, location: admin_disputes_path)
  end

protected
  
  def update_params
    options = params[:dispute].slice(:outcome)
    options[:winner] = @dispute.match.loser if options[:outcome] === 'new_match_winner'
    options
  end

  def ensure_dispute
    @dispute = Dispute.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    respond_with(nil, status: 404) do |format|
      format.html { redirect_to disputes_path, alert: 'The dispute was not found' }
    end
  end

  def ensure_can_cancel_dispute
    raise ::PermissionDenied unless @dispute.can_cancel?
  end

  def ensure_can_finalize_dispute
    raise ::PermissionDenied unless @dispute.can_finalize?
  end

end
