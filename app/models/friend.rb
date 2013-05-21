class Friend
  include Mongoid::Document

  after_create :increment_user_friend_count
  after_destroy :decrement_user_friend_count

  field :_id, :type => String, :default => proc{ "#{self.user_id}-#{self.friend_user_id}" }

  validates :_id, :uniqueness=>true

  belongs_to :user
  belongs_to :friend_user, :class_name=>"User"

protected

  def increment_user_friend_count
    user.inc(:friend_count, 1)
  end

  def decrement_user_friend_count
    user.inc(:friend_count, -1)
  end

end
