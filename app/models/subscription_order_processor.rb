class SubscriptionOrderProcessor
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :length, :use_payment_profile, :stripe_token, :subscription, :order, :user

  validates :length, presence: true

  def initialize(attributes = {}) 
    attributes.each { |name, value| send("#{name}=", value) }
  end 

  def persisted?
    false
  end 

  def process
    subscription.increase_expiration_date(length)
    return false unless subscription.valid?

    self.order = new_order_for_subscription

    stripe_charge = Stripe::Charge.create(charge_params(order))
    order.stripe_charge_id = stripe_charge.id

    handle_failed_to_save_order unless order_saved = order.save

    handle_failed_to_save_subscription unless subscription_saved = subscription.save

    subscription.process!

    order_saved && subscription_saved
  rescue Stripe::CardError => e
    self.errors[:base] << e.message
    false
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating charge: #{e.message}"
    self.errors[:base] << "We were unable to charge your credit card."
    false
  end

  def charge_params(order)
    options = {amount: (order.total * 100).to_i, currency: 'usd', description: order.user.try(:email), capture: true}
    if use_payment_profile
      options[:customer] = user.stripe_customer_token
    else
      options[:card] = stripe_token
    end
    options
  end

  def new_order_for_subscription
    new_order = Order.new({user: user})
    new_order.items << OrderItem.new({description: "1 Month Pro Subscription", price: subscription.price, quantity: length})
    new_order.update_totals
    new_order
  end

  # TODO: maybe we should email an admin?
  def handle_failed_to_save_order
    logger.error "Failed to save the order when creating a subscription: #{order.errors.full_messages}"
    self.errors[:base] << "There was a problem saving your order."
  end

  # TODO: maybe we should email an admin?
  def handle_failed_to_save_subscription
    logger.error "Failed to save/update the subscription: #{subscription.errors.full_messages}"
    self.errors[:base] << "There was a problem saving your subscription."
  end

end
