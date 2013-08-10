module Api
  module Disputes
    class DisputesController < Api::ApplicationController
      before_filter :authenticate_node_api!
      before_filter :ensure_dispute

      respond_to :json

      protected

        def ensure_count
          raise ::UnprocessableEntity, "Missing count parameter" if params[:count].blank?
        end

        def ensure_dispute
          raise ::UnprocessableEntity, "Missing id parameter" if params[:id].blank?

          @dispute = Dispute.find params[:id]
        end
    end
  end
end