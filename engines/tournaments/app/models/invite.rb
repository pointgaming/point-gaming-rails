class Invite
  include Mongoid::Document

  scope :for_user, lambda { |user| where(user_id: user._id) }

  field :_id, type: String, default: proc{ "#{tournament_id}-#{user_id}" }

  belongs_to :tournament
  belongs_to :user
end
