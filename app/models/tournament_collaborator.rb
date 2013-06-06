class TournamentCollaborator
  include Mongoid::Document

  field :_id, type: String, default: proc{ "#{stream_id}-#{user_id}" }
  field :owner, type: Boolean, default: false

  belongs_to :tournament
  belongs_to :user
end
