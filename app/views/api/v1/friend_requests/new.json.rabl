object false
node :action do
  'friend_request_created'
end
child @object => :data do
  attributes :_id
  glue :user do
    attributes :username
  end
end
