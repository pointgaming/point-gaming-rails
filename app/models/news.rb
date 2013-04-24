class News
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, :default_url => ":class/:attachment/missing_:style.png", styles: {medium: '633', large: '920'}

  field :title, :type => String
  field :content, :type => String
  field :comment_count, :type => Integer, default: 0

  validates :title, :presence=>true
  validates :content, :presence=>true

  has_many :comments, class_name: 'NewsComment'
end
