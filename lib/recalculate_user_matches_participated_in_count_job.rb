class RecalculateUserMatchesParticipatedInCountJob
  include Resque::Plugins::UniqueJob

  @queue = :high

  def self.perform(user_id)
    user = User.find(user_id)
    user.update_match_participation_count
    user.save!
  end

end
