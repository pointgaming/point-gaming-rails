Fabricator(:team_member) do
  rank 'Member'
  user
  team
end

Fabricator(:team_manager, from: :team_member) do
  rank 'Manager'
end

Fabricator(:team_leader, from: :team_member) do
  rank 'Leader'
end
