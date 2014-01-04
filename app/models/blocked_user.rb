class BlockedUser
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ "#{self.user_id}-#{self.blocked_user_id}" }

  validates :_id, :uniqueness=>true

  belongs_to :user, :dependent => :nullify
  belongs_to :blocked_user, :class_name=>"User"

  def user_and_blocked_user_validation
    if (self.user_id === self.blocked_user_id)
      self.errors[:base] << "User cannot block themself"
    end
  end
end
