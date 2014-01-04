class Game
  include Mongoid::Document
  include Tire::Model::Search
  include Tire::Model::CustomCallbacks
  include Rails.application.routes.url_helpers

  field :name, :type => String, :default => ''

  field :player_count, :type => Integer, :default => 0

  has_many :rooms, class_name: 'GameRoom'
  has_many :types, class_name: 'GameType'

  validates :name, :presence=>true, :uniqueness=>true
  validates :player_count, :presence=>true

  def increment_player_count!(amount=1)
    inc(:player_count, amount)
  end

  def display_name
    name
  end

  def url
    "PointGaming:lobby:#{self._id}"
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

  settings analysis: {
      analyzer: {
        partial_match: {
          tokenizer: :whitespace,
          filter: [:lowercase, :ngram]
        }
      },
      filter: {
        ngram: {
            max_gram: 20,
            min_gram: 1,
            type: :nGram
        }
      }
    } do
    mapping do
      indexes :display_name, type: 'string', analyzer: 'snowball', boost: 10, as: 'name'
      indexes :prefix, type: 'string', index_analyzer: 'partial_match', search_analyzer: 'snowball', boost: 2, as: 'name'
      indexes :url, type: 'string', :index => 'no', as: 'url'

      indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
      indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
      indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
    end
  end

end
