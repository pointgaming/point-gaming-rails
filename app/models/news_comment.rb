class NewsComment
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :increment_comment_count
  after_destroy :decrement_comment_count

  field :text, :type => String

  validates :text, :presence=>true

  belongs_to :user
  belongs_to :news

  def self.model_name
    ActiveModel::Name.new(self, nil, "Comment")
  end

private

  def increment_comment_count
    self.news.inc :comment_count, 1
  end

  def decrement_comment_count
    self.news.inc :comment_count, -1
  end

end
