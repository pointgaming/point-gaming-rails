class FriendRequest
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ "#{self.user_id}-#{self.friend_request_user_id}" }

  belongs_to :user
  belongs_to :friend_request_user, :class_name=>"User"

  validate :user_and_friend_request_user_validation

  def user_and_friend_request_user_validation
    if (self.user_id === self.friend_request_user_id)
      self.errors[:base] << "User cannot send themself a friend request"
    end
  end
end
