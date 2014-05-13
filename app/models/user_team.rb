class UserTeam
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :team
  belongs_to :owner, class_name: 'User'
  belongs_to :game_room

  validates :user, :team, :owner, :game_room, presence: true
end
