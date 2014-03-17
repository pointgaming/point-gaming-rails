attributes :_id, :start_time, :period
child :owner do
  extends "users/base"
end
