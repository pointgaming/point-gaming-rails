class DisputeMatchLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :modified, :type => Hash
  field :original, :type => Hash
  field :action, :type => String

  embedded_in :dispute
end
