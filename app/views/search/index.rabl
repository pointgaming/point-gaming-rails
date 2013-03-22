collection :@results, root: false
attributes :_id
node :name do |d|
  d.display_name
end
node :url do |d|
  url_for d
end
node :type do |d|
  d.class.name
end
