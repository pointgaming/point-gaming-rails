class Game
  include Mongoid::Document

  field :name, :type => String, :default => ''

  field :player_count, :type => Integer, :default => 0

  has_many :rooms

  validates :name, :presence=>true, :uniqueness=>true
  validates :player_count, :presence=>true
end
