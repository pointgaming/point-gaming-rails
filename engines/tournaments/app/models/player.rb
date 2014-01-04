class Player
  include Mongoid::Document

  after_create :increment_tournament_player_count
  after_destroy :decrement_tournament_player_count

  scope :for_user, lambda { |user| where(user_id: user._id) }

  field :_id, type: String, default: proc{ "#{tournament_id}-#{user_id}" }
  field :checked_in_at, type: DateTime

  index({ _id: 1 }, { unique: true })

  belongs_to :tournament
  belongs_to :user

  def checked_in?
    checked_in_at.is_a?(DateTime)
  end

  private

  def increment_tournament_player_count
    self.tournament.increment_player_count(1)
  end

  def decrement_tournament_player_count
    self.tournament.increment_player_count(-1)
  end
end
