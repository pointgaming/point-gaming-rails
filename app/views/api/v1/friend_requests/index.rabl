object false
node :success do
  true 
end
child(:@friend_requests) do
  extends "api/v1/friend_requests/base"
end
