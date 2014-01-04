class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :active, lambda { where(:expiration_date.gte => Date.today ) }
  scope :pending_processing, lambda { active.where(:next_processing_date.lte => Date.today ) }

  attr_accessor :length

  field :expiration_date, type: Date
  field :next_processing_date, type: Date

  belongs_to :user, inverse_of: :subscriptions

  validates :expiration_date, presence: true
  validates :next_processing_date, presence: true

  def days_until_expiration_date
    number_of_days = expiration_date - Time.now.to_date
    number_of_days.to_i
  end

  def points
    500
  end

  def price
    BigDecimal.new("5.00")
  end

  def increase_expiration_date(number_of_months)
    current_expiration = expiration_date || Date.today
    self.expiration_date = number_of_months.to_i.months.since(current_expiration)
  end

  def reset_expiration_date!
    if expiration_date_changed?
      self.expiration_date = expiration_date_was
    end
  end

  def process!
    return if next_processing_date > Date.today
  
    UserPointService.new(user).create(points, self)

    self.next_processing_date = 1.month.since(self.next_processing_date)

    save
  end

end
