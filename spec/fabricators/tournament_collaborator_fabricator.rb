Fabricator(:tournament_collaborator) do
  tournament
  user
  owner false
end
