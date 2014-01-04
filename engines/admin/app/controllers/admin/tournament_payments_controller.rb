module Admin
  class TournamentPaymentsController < Admin::ApplicationController
    before_filter :ensure_tournament
    before_filter :ensure_user_can_approve_tournament_payment

    respond_to :html, :json

    private

    def ensure_tournament
      @tournament = Tournament.find(params[:tournament_id])
    rescue Mongoid::Errors::DocumentNotFound
      respond_with_error("The tournament was not found",
                          status: 404, location: tournaments_path)
    end

    def ensure_user_can_approve_tournament_payment
      unless TournamentPaymentPolicy.new(current_user, @tournament).approve?
        respond_with_error("You do not have permission to perform that action",
                           status: 403, location: tournament_path(@tournament))
      end
    end
  end
end
