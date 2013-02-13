class Collaborator
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ "#{self.stream_id}-#{self.user_id}" }
  field :owner, :type => Boolean, :default => false

  belongs_to :stream
  belongs_to :user
end
