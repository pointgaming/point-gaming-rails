class SubscriptionOrderProcessor
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :length, :use_payment_profile, :stripe_token, :subscription, :user
  attr_reader :order

  validates :length, presence: true

  def initialize(attributes = {}) 
    attributes.each { |name, value| send("#{name}=", value) }
  end 

  def persisted?
    false
  end 

  def charge_payment
    stripe_charge = Stripe::Charge.create(charge_params)
    order.stripe_charge_id = stripe_charge.id
  rescue Stripe::CardError => e
    add_error e.message
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating charge: #{e.message}"
    add_error "We were unable to charge your credit card."
  end

  def process
    increase_subscription_length
    build_order

    unless errors.present?
      charge_payment

      unless errors.present?
        save_order
        save_subscription

        subscription.process!
      end
    end

    success = !errors.present?
  ensure
    subscription.reset_expiration_date! unless success
  end

  private

    def add_error(message)
      add_error message
    end

    def increase_subscription_length
      subscription.increase_expiration_date(length)

      unless subscription.valid?
        add_error 'Error increasing subscription length'
      end
    end

    def charge_params
      options = {amount: (order.total * 100).to_i, currency: 'usd', description: order.user.try(:email), capture: true}
      if use_payment_profile
        options[:customer] = user.stripe_customer_token
      else
        options[:card] = stripe_token
      end
      options
    end

    def build_order
      @order = Order.new({user: user})
      order.add_item(build_order_item)
    end

    def build_order_item
      OrderItem.new({
        description: "1 Month Pro Subscription",
        price: subscription.price,
        quantity: length
      })
    end

    def log_user_order
      UserOrderLoggerService.new(user: user, order: order).log
    end

    def save_order
      if order.save
        log_user_order
      else
        logger.error "Failed to save the order when creating a subscription: #{order.errors.full_messages}"
        add_error "There was a problem saving your order."
      end
    end

    def save_subscription
      unless subscription.save
        logger.error "Failed to save the subscription: #{subscription.errors.full_messages}"
        add_error "There was a problem saving your subscription."
      end
    end
end
