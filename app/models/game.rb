class Game
  include Mongoid::Document
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Rails.application.routes.url_helpers

  field :name, :type => String, :default => ''

  field :player_count, :type => Integer, :default => 0

  has_many :rooms, class_name: 'GameRoom'

  validates :name, :presence=>true, :uniqueness=>true
  validates :player_count, :presence=>true

  def display_name
    name
  end

  def url
    game_url(self)
  end

  def mq_exchange
    "Game_#{_id}"
  end

  def store_sort
    90
  end

  def main_sort
    0
  end

  def forum_sort
    90
  end

  mapping do
    indexes :display_name, type: 'string', boost: 10, analyzer: 'snowball', as: 'name'
    indexes :url, type: 'string', :index => 'no', as: 'url'

    indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
    indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
    indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
  end

end
