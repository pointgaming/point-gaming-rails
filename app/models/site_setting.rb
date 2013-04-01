class SiteSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :value

  field :key, :type => String
  field :value, :type => String

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
end
