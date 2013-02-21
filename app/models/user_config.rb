class UserConfig
  include Mongoid::Document
  include Mongoid::Paperclip

  field :name, type: String

  belongs_to :user, inverse_of: :configs

  has_mongoid_attached_file :attachment

  attr_accessible :attachment, :name

  validates :name, presence: true
  validates_attachment :attachment, :presence => true, :size => { :in => 0..1.megabytes }
end
