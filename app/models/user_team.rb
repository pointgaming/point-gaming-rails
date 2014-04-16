class UserTeam
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :team
  belongs_to :owner, class_name: 'User'

  validates :user, :team, :owner, presence: true
end
