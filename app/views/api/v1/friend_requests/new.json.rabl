object false
node :action do
  'new_friend_request'
end
child @object => :user do
  attributes :_id, :username
  node :status do
    'invited'
  end
end
