module Admin
  class TournamentsController < Admin::ApplicationController
    before_filter :ensure_tournament, except: [:index]
    before_filter :ensure_payment, only: [:payment, :deny]

    respond_to :html, :json

    def index
      @tournaments = Tournament.send(params[:approved] == "1" ? :activated : :pending).order_by(updated_at: :desc).all

      respond_with(@tournaments)
    end

    def show
      render @tournament
    end

    def payment
      respond_with(@payment)
    end

    def approve
      @tournament.payment_approved!
      respond_with(@tournament, location: tournaments_path)
    end

    def deny
      @tournament.payment_denied! && @payment.destroy
      respond_with(@tournament, location: tournaments_path)
    end

    private

    def ensure_tournament
      @tournament = Tournaments::Tournament.find_by(slug: params[:id])

      can = current_user.can?(:manage, Tournaments::Tournament)

      respond_with_error("You do not have permission to perform that action", status: 403, location: root_path) unless can
    rescue Mongoid::Errors::DocumentNotFound
      respond_with_error("The tournament was not found",
                          status: 404, location: tournaments_path)
    end

    def ensure_tournament_payment
      @payment = @tournament.payment
      respond_with_error("The payment was not found", status: 404, location: @tournament) unless @payment
    end
  end
end
