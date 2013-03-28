class Stream
  include Mongoid::Document
  include Mongoid::Paperclip

  before_validation :populate_slug

  has_mongoid_attached_file :thumbnail, :default_url => ":class/:attachment/missing_:style.png", :styles => {:thumb => '300x200!'}

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

  def mq_exchange
    "s.#{_id}"
  end

private

  def populate_slug
    self.slug = name.downcase.gsub(/\s/, "_") if name.present?
    true
  end

end
