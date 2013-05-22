class GameType
  include Mongoid::Document

  field :name, type: String, default: ''
  field :sort_order, type: Integer, default: 0

  validates :name, presence: true, uniqueness: {scope: :game_id}

  belongs_to :game
end
