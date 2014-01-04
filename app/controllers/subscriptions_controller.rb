class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_params_exist, only: [:create, :update]
  before_filter :ensure_active_subscription, only: [:edit, :update]
  before_filter :ensure_stripe_customer, only: [:index]

  def index
    @subscription = current_user_subscription
    if @subscription.present?
      render 'current'
    else
      @subscription_features = SubscriptionFeature.order_by(:sort_order => 'ASC').all
      @subscription_types = SubscriptionType.order_by(:sort_order => 'ASC').all
    end
  end

  def new
    @subscription = Subscription.new
    @subscription_order_processor = SubscriptionOrderProcessor.new
  end

  def create
    @subscription = Subscription.new({user: current_user, next_processing_date: Date.today})

    @subscription_order_processor = SubscriptionOrderProcessor.new(subscription_processor_params)
    if @subscription_order_processor.process
      redirect_to order_path(@subscription_order_processor.order)
    else
      render action: :new
    end
  end

  def edit
    @subscription_order_processor = SubscriptionOrderProcessor.new
  end

  def update
    @subscription_order_processor = SubscriptionOrderProcessor.new(subscription_processor_params)
    if @subscription_order_processor.process
      redirect_to order_path(@subscription_order_processor.order)
    else
      render action: :edit
    end
  end

protected

  def ensure_stripe_customer
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_token) rescue nil
  end

  def ensure_active_subscription
    @subscription = current_user.subscriptions.active.first

    unless @subscription.present?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to subscriptions_path, alert: 'An active subscription is required to view that page.' }
      end
    end
  end

  def ensure_params_exist
    if params[:use_payment_profile].blank? && params[:stripeToken].blank?
      respond_with(nil, status: 422) do |format|
        format.html { redirect_to :back, alert: 'Missing payment parameter' }
      end
    end
  end

  def subscription_processor_params
    {
      length: params[:subscription_order_processor][:length],
      use_payment_profile: params[:use_payment_profile],
      stripe_token: params[:stripeToken],
      user: current_user,
      subscription: @subscription
    }
  end

  def current_user_subscription
    current_user.subscriptions.active.first
  end

end
