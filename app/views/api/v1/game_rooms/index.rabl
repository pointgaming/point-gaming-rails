object false
child(:@game_rooms) do
  attributes :_id, :position, :is_advertising, :is_locked, :member_count, :max_member_count, :description, :game_id
  child :owner do
    attributes :_id, :username
  end
end
