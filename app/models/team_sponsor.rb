class TeamSponsor
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, :default_url => "/system/:class/:attachment/missing_:style.png", styles: {thumb: '50x50', medium: '200'}

  field :name, type: String
  field :url, type: String
  field :sort_order, type: Integer, default: 0

  belongs_to :team

  attr_accessible :image, :name, :url, :sort_order

  validates :name, presence: true
  validates :url, presence: true
  validates :team, presence: true
  validates :sort_order, presence: true
  validates_attachment :image, :presence => true, :size => { :in => 0..4.megabytes }
end
