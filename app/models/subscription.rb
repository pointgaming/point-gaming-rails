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

  def points
    500
  end

  def price
    BigDecimal.new("5.00")
  end

  def increase_expiration_date(number_of_months)
    current_expiration = self.expiration_date || Date.today
    self.expiration_date = number_of_months.to_i.months.since(current_expiration)
  end

  def process!
    return if self.next_processing_date > Date.today
  
    self.user.increment_points!(points)

    self.next_processing_date = 1.month.since(self.next_processing_date)

    self.save
  end

end
