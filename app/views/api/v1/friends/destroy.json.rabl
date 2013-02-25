object false
node :action do
  'friend_destroyed'
end
child @object => :user do
  attributes :_id, :username
  node :status do
    'removed'
  end
end
