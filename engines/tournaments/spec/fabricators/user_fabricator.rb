Fabricator(:user) do
  username { Faker::Internet.user_name }
  last_name "Derpina"
  password "watwat"
  points 500
  country "Murica"
  phone "(999) 555-4444"
  registration_pin "pgrpin"

  after_build do |user|
    user.first_name = user.username
    user.email = "#{user.username}@pointgaming.com"
  end
end
