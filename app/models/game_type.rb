class GameType
  include Mongoid::Document

  field :name, type: String, default: ''

  validates :name, presence: true, uniqueness: true

end
