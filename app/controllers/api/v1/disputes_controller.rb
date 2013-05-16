class Api::V1::DisputesController < Api::ApplicationController
  before_filter :authenticate_node_api!
  before_filter :ensure_dispute

  respond_to :json

  def show
    respond_with(@dispute)
  end

  def incrementAdminViewerCount
    raise ::UnprocessableEntity, "Missing count parameter" if params[:count].blank?
    @dispute.increment_admin_viewer_count!(params[:count])
    respond_with(@dispute)
  end

  def incrementUserViewerCount
    raise ::UnprocessableEntity, "Missing count parameter" if params[:count].blank?
    @dispute.increment_user_viewer_count!(params[:count])
    respond_with(@dispute)
  end

protected

  def ensure_dispute
    raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

    @dispute = Dispute.find params[:id]
  end

end
