# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'Setting up default games:'

games = [
  'Counter-Strike: Go',
  'League of Legends',
  'StarCraft II',
  'Counter-Strike: Source',
  'Quake 3',
  'Quake Live'
]
games.each {|game_name| 
  game = Game.create! :name => game_name, :player_count => 0
  puts 'New game created: ' << game.name

  puts 'Creating 100 game rooms...'
  100.times { |i|
    game.rooms.create!({:description => "Room #{i}"})
  }
}


puts 'Creating Tournaments'

game = Game.find_by(name: 'Quake Live')
Tournament.create! :start_datetime => Time.now, :game => game, :game_type => 'Duel', :prize_pool => '$1,000 Cash/1000 Points', :player_limit => 5000, :player_count => 3492

game = Game.find_by(name: 'Quake 3')
Tournament.create! :start_datetime => Time.now, :game => game, :game_type => 'CTF', :prize_pool => '$1,000 Cash/1000 Points', :player_limit => 1000, :player_count => 459

game = Game.find_by(name: 'Counter-Strike: Go')
Tournament.create! :start_datetime => Time.now, :game => game, :game_type => 'Team 5vs5', :prize_pool => '$20,000 Cash/50,000 Points', :player_limit => 50000, :player_count => 12361

groups = [
  {name: 'CEO/COO', prefix: '~'},
  {name: 'Executive', prefix: '@'},
  {name: 'Super Admin', prefix: '#'},
  {name: 'Admin', prefix: '$'},
  {name: 'Dispute Admin', prefix: '%'},
  {name: 'Forums Admin', prefix: '^'},
  {name: 'Forums Moderator', prefix: '&'}
]
groups.each_with_index {|group, index| 
  group['sort_order'] = index unless group.has_key?(:sort_order)
  Group.create! group
}
