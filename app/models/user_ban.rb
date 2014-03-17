class UserBan

  include Mongoid::Document
  include Mongoid::Timestamps
	
  field :start_time, type: DateTime, default: Time.now
  field :period, type: Float, default: 1
  
  belongs_to :game
  belongs_to :user
  belongs_to :owner, class_name: 'User'

  validates :game, :user, :owner, presence: true

  def is_expired?
    return (self.start_time + period.hours) < Time.now
  end
end
