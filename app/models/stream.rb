class Stream
  include Mongoid::Document
  include Mongoid::Paperclip
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Rails.application.routes.url_helpers

  before_validation :populate_slug
  before_save :sanitize_embedded_html

  has_mongoid_attached_file :thumbnail, :default_url => ":class/:attachment/missing_:style.png", :styles => {:tiny => '50x50!', :thumb => '300x200!'}

  field :name, :type => String, :default => ''
  field :slug, :type => String, :default => ''
  field :details, :type => String, :default => ''
  field :streaming, :type => Boolean, :default => false
  field :embedded_html

  field :viewer_count, :type => Integer, :default => 0

  belongs_to :game
  belongs_to :match

  has_many :matches, as: :room
  has_many :collaborators, dependent: :destroy

  validates :name, :presence=>true, uniqueness: true, :format => {:with => APP_CONFIG[:display_name_regex], message: APP_CONFIG[:display_name_regex_message]}
  validates :slug, presence: true, uniqueness: true
  validates :viewer_count, :presence=>true

  def to_param
    self.slug
  end

  def owner
    Collaborator.where(stream_id: self.id, owner: true).first
  end

  def display_name
    name
  end

  def url
    stream_url(self)
  end

  def mq_exchange
    "Stream_#{_id}"
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
    indexes :description, type: 'string', analyzer: 'snowball', as: 'details'
    indexes :url, type: 'string', :index => 'no', as: 'url'

    indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
    indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
    indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
  end

private

  def populate_slug
    self.slug = name.downcase.gsub(/\s/, "_") if name.present?
    true
  end

  def sanitize_embedded_html
    if self.embedded_html_changed? && self.embedded_html.present?
      self.embedded_html = Sanitize.clean(self.embedded_html, Sanitize::Config::EMBEDDED_CONTENT)
    end
  end

end
