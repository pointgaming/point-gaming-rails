module Admin
  class ApplicationController < ::ApplicationController
    before_filter :authenticate_user!
    before_filter :ensure_admin

    def sub_layout
      "admin"
    end

    private

    def respond_with_error(message, status: 422, location: :back)
      respond_with({ errors: [message] }, status: status) do |format|
        format.html { redirect_to location, alert: message }
      end
    end

    def ensure_admin
      raise ::PermissionDenied unless current_user.admin?
    end
  end
end
