attributes :_id, :username, :points
child :teams do
  extends "teams/base"
end
