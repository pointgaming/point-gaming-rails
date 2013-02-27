class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String, :default => ''
  field :tag, :type => String, :default => ''

  field :member_count, :type => Integer, :default => 0

  has_many :members, class_name: 'TeamMember', dependent: :destroy

  validates :name, :presence=>true
  validates :tag, :presence=>true

  def playable_name
    name
  end
end
