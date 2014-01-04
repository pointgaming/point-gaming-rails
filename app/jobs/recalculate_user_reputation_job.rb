class RecalculateUserReputationJob
  include Resque::Plugins::UniqueJob

  @queue = :high

  def self.perform(user_id)
    user = User.find(user_id)
    user.update_reputation
    user.save!
  end

end
