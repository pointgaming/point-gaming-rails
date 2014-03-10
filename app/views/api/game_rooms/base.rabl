attributes :_id, :position, :is_advertising, :is_locked, :member_count, :max_member_count, :description, :game_id
child :owner do
  extends "users/base"
end
child :members do
  extends "users/base"
end
child :admins do
  extends 'users/base'
end
