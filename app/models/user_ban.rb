class UserBan

  include Mongoid::Document
  include Mongoid::Timestamps
	
  field :start_time, type: DateTime, default: Time.now
  field :period, type: Float, default: 1
  
  belongs_to :game
  belongs_to :user
  belongs_to :owner, class_name: 'User'

  validates :game, :user, :owner, presence: true
  validate :not_banned_himself

  def is_expired?
    return ((!self.period.eql?(-1.0)) and ((self.start_time.utc + period.hours) < Time.now.utc))
  end

  protected

  def not_banned_himself
    self.errors[:base] << "User cannot ban himself" if owner.eql?(user)
  end
end
