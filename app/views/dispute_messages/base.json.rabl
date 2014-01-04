attributes :_id, :text
node :created_at do |d|
  d.created_at
end
node :anchor do |d|
  d.anchor
end
node :url do |d|
  d.url
end
node :attachment_name do |d|
  d.attachment.present? ? d.attachment_file_name : nil
end
node :attachment_url do |d|
  d.attachment.present? ? d.attachment.url : nil
end
child :user do
  attributes :_id, :username
  node :avatar_url do |d|
    d.avatar.url(:thumb)
  end
  node :url do |d|
    d.profile_url
  end
end
