module Api
  module Disputes
    class DisputesController < Api::Disputes::ContextController
      before_filter :ensure_count, only: [:incrementAdminViewerCount,:incrementUserViewerCount]

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
    end
  end
end