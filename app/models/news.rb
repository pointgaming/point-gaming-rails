class News
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, :default_url => ":class/:attachment/missing_:style.png", :styles => {:medium => '633'}

  field :title, :type => String
  field :content, :type => String

  validates :title, :presence=>true
  validates :content, :presence=>true
end
