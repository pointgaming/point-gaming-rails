collection :@results, root: false
attributes :_id
node :name do |d|
  d.playable_name
end
node :type do |d|
  d.class.name
end
