class RecalculateTeamPointsJob
  include Resque::Plugins::UniqueJob

  @queue = :high

  def self.perform(team_id)
    team = Team.find(team_id)

    point_summary = team.active_users.all.reduce([0, {}]) do |summary, member|
      summary[0] += member.points
      summary[1][member.game_id] = (summary[1][member.game_id] || 0) + member.points
      summary
    end

    team.points = point_summary[0]
    team.game_points = point_summary[1]
    team.save!
  end

end
