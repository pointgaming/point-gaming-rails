object false
node :action do
  'friend_request_created'
end
child @object => :data do
  attributes :_id
  child :user => :from_user do
    attributes :_id, :username
  end
  child :friend_request_user => :to_user do
    attributes :_id, :username
  end
end
