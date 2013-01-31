class AuthToken
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ UUIDTools::UUID.random_create.to_s }
  field :expired, :type => Boolean, :default => false

  belongs_to :user, :dependent => :nullify
end
