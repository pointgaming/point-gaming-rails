class Ignore
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ self.user_id + "-" + self.ignore_user_id }

  validates :_id, :uniqueness=>true

  belongs_to :user, :dependent => :nullify
  belongs_to :ignore_user, :class_name=>"User"
end
