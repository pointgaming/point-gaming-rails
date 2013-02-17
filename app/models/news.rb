class News
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String
  field :content, :type => String

  validates :title, :presence=>true
  validates :content, :presence=>true
end
