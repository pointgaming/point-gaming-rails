class BillingController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_stripe_token, only: [:create, :update]
  before_filter :ensure_user_needs_new_token, only: [:new, :create]
  before_filter :ensure_stripe_customer, only: [:show, :update]

  def show

  end

  def create
    @stripe_customer = Stripe::Customer.create(description: current_user.email, card: params[:stripeToken])
    current_user.stripe_customer_token = @stripe_customer.id
    if current_user.save
      redirect_to billing_path(1), notice: "Your billing information was saved successfully."
    else
      render action: :index
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    flash[:alert] = "There was a problem with your credit card."
    render action: :new
  end

  def update
    @stripe_customer.description = current_user.email
    @stripe_customer.card = params[:stripeToken]
    if @stripe_customer.save
      redirect_to billing_path(1), notice: "Your billing information was saved successfully."
    else
      render action: :edit
    end
  end

private

  def ensure_stripe_customer
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_token)
  end

  def ensure_stripe_token
    redirect_to new_billing_path, alert: "Unable to save billing information." unless params[:stripeToken]
  end

  def ensure_user_needs_new_token
    redirect_to billing_path(1) if current_user.has_stripe_token?
  end

end
