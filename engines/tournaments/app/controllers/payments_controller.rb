class PaymentsController < EngineController
  before_filter :ensure_tournament
  before_filter :ensure_tournament_payment_required
  before_filter :ensure_tournament_editable_by_user, only: [:edit, :update]

  def new
    @payment = @tournament.build_payment
  end

  def create
    @payment = @tournament.build_payment(create_params)
    @payment.save
    respond_with(@payment, location: next_tournament_path)
  end

  private

  def create_params
    params.fetch(:payment).merge(user: current_user, amount: @tournament.prizepool_total)
  end

  def ensure_tournament_payment_required
    unless @tournament.payment_required?
      message = "Unable to add a payment to that tournament"
      respond_with({errors: [message]}, status: 403) do |format|
        format.html { redirect_to @tournament, alert: message }
      end
    end
  end
end
