class Game
  include Mongoid::Document

  field :name, :type => String, :default => ''

  field :player_count, :type => Integer, :default => 0

  has_many :rooms, class_name: 'GameRoom'

  validates :name, :presence=>true, :uniqueness=>true
  validates :player_count, :presence=>true

  def display_name
    name
  end

  def mq_exchange
    "Game_#{_id}"
  end
end
