class AuthToken
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ UUIDTools::UUID.random_create.to_s }

  belongs_to :user, :dependent => :nullify
end
