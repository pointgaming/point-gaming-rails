attributes :_id, :start_time, :period
child :user do
  extends "users/base"
end
child :owner do
  extends "users/base"
end
