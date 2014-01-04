class UserTransactionHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :recent, lambda { where(:created_at.gte => 30.days.ago) }

  field :description

  belongs_to :user

  # this should be an instance of any object that describes why this change occurred
  field :action_source_id
  field :action_source_type

  validates :description, presence: true
  validates :action_source_id, presence: true
  validates :action_source_type, presence: true

  def action_source
    action_source_type.constantize.find(action_source_id)
  end

  def days_since
    (DateTime.now - created_at.to_datetime).to_i
  end

end
