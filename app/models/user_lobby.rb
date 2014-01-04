class UserLobby
  include Mongoid::Document

  belongs_to :user
  belongs_to :game

  validates :user, presence: true, uniqueness: { scope: :game }
  validates :game, presence: true
end
