object false
node :action do
  'new_friend'
end
child @object => :user do
  attributes :_id, :username
  node :status do
    'added'
  end
end
