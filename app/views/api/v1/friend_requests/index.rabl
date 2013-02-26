object false
child(:@friend_requests) do
  attributes :_id
  child :user => :from_user do
    attributes :_id, :username
  end
  child :friend_request_user => :to_user do
    attributes :_id, :username
  end
end
