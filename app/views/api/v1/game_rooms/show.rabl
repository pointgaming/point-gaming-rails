object :@game_room
attributes :_id, :position, :is_advertising, :is_locked, :member_count, :max_member_count, :description
child(:owner) { attributes :_id, :username }
