class Team
  include Mongoid::Document
  include Mongoid::Timestamps

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

private

  def populate_slug
    self.slug = name.downcase.gsub(/\s/, "_") if name.present?
    true
  end

end
