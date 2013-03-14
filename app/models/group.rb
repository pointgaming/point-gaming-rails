class Group
  include Mongoid::Document

  field :name, :type => String
  field :prefix, :type => String
  field :sort_order, :type => Integer, default: 0
  field :permissions, type: Array

  validates :name, presence: true, uniqueness: true
  validates :prefix, uniqueness: true, length: {maximum: 1}, allow_blank: true

  has_many :users
end
