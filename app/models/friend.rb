class Friend
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ "#{self.user_id}-#{self.friend_user_id}" }

  validates :_id, :uniqueness=>true

  belongs_to :user
  belongs_to :friend_user, :class_name=>"User"
end
