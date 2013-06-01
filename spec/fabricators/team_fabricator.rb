Fabricator(:team) do
  name { sequence(:name) { |i| "Team#{i}" } }
  tag { sequence(:slug) { |i| "[te#{i}]" } }
end

Fabricator(:team_with_members, from: :team) do
  after_create do |team|
    3.times do |i|
      if i === 0
        team.members << Fabricate(:team_leader, team: team) 
      elsif i % 2 === 0
        team.members << Fabricate(:team_member, team: team) 
      else
        team.members << Fabricate(:team_manager, team: team) 
      end
    end
  end
end
