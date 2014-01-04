class Collaborator
  include Mongoid::Document

  field :_id, :type => String, :default => proc{ "#{self.stream_id}-#{self.user_id}" }
  field :owner, :type => Boolean, :default => false

  after_create :increment_user_stream_owner_count
  after_destroy :decrement_user_stream_owner_count

  belongs_to :stream
  belongs_to :user

private

  def increment_user_stream_owner_count
    self.user.inc :stream_owner_count, 1 if self.owner.present?
  end

  def decrement_user_stream_owner_count
    self.user.inc :stream_owner_count, -1 if self.owner.present?
  end
end
