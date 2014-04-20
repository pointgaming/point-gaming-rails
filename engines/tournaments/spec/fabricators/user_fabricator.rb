Fabricator(:user) do
  first_name { |user| user[:username] }
  last_name "Derpina"
  email { |user| "#{user[:username]}@pointgaming.com" }
  password "watwat"
  password_confirmation { |user| user[:password] }
  points 500
  country "Murica"
  phone "(999) 555-4444"
  registration_pin "1337"
end
