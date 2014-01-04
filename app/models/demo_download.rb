class DemoDownload
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :demo

  validates :user, presence: true, uniqueness: {scope: :demo}
  validates :demo, presence: true

end
