object :@game_room
attributes :_id, :position, :is_advertising, :is_locked, :member_count, :max_member_count, :description, :game_id
child(:owner) { attributes :_id, :username }
