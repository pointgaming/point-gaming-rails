class UserMute
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :game_room
  belongs_to :owner, class_name: 'User'

  validates :user, :game_room, presence: true 
end
