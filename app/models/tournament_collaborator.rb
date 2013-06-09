class TournamentCollaborator
  include Mongoid::Document

  scope :for_user, lambda{|user| where(user_id: user._id) }
  scope :ownership, lambda{ where(owner: true) }

  field :_id, type: String, default: proc{ "#{tournament_id}-#{user_id}" }
  field :owner, type: Boolean, default: false

  belongs_to :tournament
  belongs_to :user
end
