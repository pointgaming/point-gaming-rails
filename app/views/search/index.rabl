collection :@results, root: false
attributes :_id
node :name do |d|
  d.display_name
end
node :url do |d|
  d.url
end
node :type do |d|
  d.type
end
