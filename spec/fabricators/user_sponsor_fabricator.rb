Fabricator(:user_sponsor) do
  name { sequence(:name) {|i| "Sponsor #{i}"} }
  url 'http://www.google.com'
  sort_order { sequence(:sort_order) {|i| i} }
  user
  image { File.open(File.join(Rails.root, 'spec', 'fabricators', 'images', 'image.jpg'))}
end
