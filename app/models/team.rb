class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Rails.application.routes.url_helpers

  before_validation :populate_slug

  field :name, :type => String, :default => ''
  field :slug, :type => String, :default => ''
  field :tag, :type => String, :default => ''

  field :member_count, :type => Integer, :default => 0

  has_many :members, class_name: 'TeamMember', dependent: :destroy

  validates :name, presence: true, uniqueness: true, :format => {:with => APP_CONFIG[:display_name_regex], message: APP_CONFIG[:display_name_regex_message]}
  validates :slug, presence: true, uniqueness: true
  validates :tag, presence: true

  def to_param
    self.slug
  end

  def display_name
    name
  end

  def url
    team_url(self)
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
          filter: [:lowercase, :edge_ngram]
        }
      },
      filter: {
        edge_ngram: {
            side: :front,
            max_gram: 20,
            min_gram: 1,
            type: :edgeNGram
        }
      }
    } do
    mapping do
      indexes :display_name, type: 'string', boost: 10, analyzer: 'snowball', as: 'name'
      indexes :prefix, type: 'string', index_analyzer: 'partial_match', search_analyzer: 'snowball', boost: 2, as: 'name'
      indexes :url, type: 'string', :index => 'no', as: 'url'

      indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
      indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
      indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
    end
  end

private

  def populate_slug
    self.slug = name.downcase.gsub(/\s/, "_") if name.present?
    true
  end

end
