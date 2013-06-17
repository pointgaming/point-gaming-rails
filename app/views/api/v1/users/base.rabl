attributes :_id, :username, :points
node :group_prefix do |user|
  user.group.try(:prefix)
end
child :team do
  extends "api/v1/teams/base"
end
