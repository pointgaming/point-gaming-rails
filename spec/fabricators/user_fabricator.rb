Fabricator(:user) do
  first_name 'Bruce'
  last_name 'Wayne'
  username { sequence(:username) { |i| "bruce#{i}" } }
  email { sequence(:email) { |i| "bruce#{i}@wayne.com" } }
  password 'myawesomepassword'
  registration_pin 'pgrpin'
end

Fabricator(:evil_trout, from: :user) do
  first_name 'Evil'
  last_name 'Trout'
  username 'eviltrout'
  email 'eviltrout@somewhere.com'
  password 'imafish'
end

Fabricator(:walter_white, from: :user) do
  first_name 'Walter'
  last_name 'White'
  username 'heisenberg'
  email 'wwhite@bluemeth.com'
  password 'letscook'
end

Fabricator(:admin, from: :user) do
  first_name 'Anne'
  last_name 'Admin'
  username 'anne'
  email 'anne@discourse.org'
  admin true
end

Fabricator(:another_admin, from: :user) do
  first_name 'Anne'
  last_name 'Admin the 2nd'
  username 'anne2'
  email 'anne2@discourse.org'
  admin true
end

Fabricator(:newuser, from: :user) do
  first_name 'Newbie'
  last_name 'Newperson'
  username 'newbie'
  email 'newbie@new.com'
end
