class TournamentPaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_tournament
  before_filter :ensure_tournament_payment_required
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update]

  respond_to :html, :json

  def new
    @tournament_payment = @tournament.build_payment
  end

  def create
    @tournament_payment = @tournament.build_payment(create_params)
    @tournament_payment.save
    respond_with(@tournament_payment, location: @tournament.next_user_tournament_path)
  end

  private

  def create_params
    params.fetch(:tournament_payment).merge(user: current_user, amount: @tournament.prizepool_total)
  end

  def ensure_tournament
    @tournament = Tournament.find params[:user_tournament_id]
  end

  def ensure_tournament_payment_required
    unless @tournament.payment_required?
      message = 'Unable to add a payment to that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournament_path(@tournament), alert: message }
      end
    end
  end

  def ensure_tournament_editable_by_user
    unless @tournament.editable_by_user?(current_user)
      message = 'You do not have permission to edit that tournament'
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to user_tournaments_path, alert: message }
      end
    end
  end

end
