class Profile
  include Mongoid::Document

  field :bio, type: String

  embeds_one :rig

  attr_accessible :rig_attributes, :bio

  accepts_nested_attributes_for :rig
end
