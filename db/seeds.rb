# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'Setting up default games:'

games = [
  'Quake Live',
  'Counter-Strike (All Versions)'
]
games.each {|game_name| 
  game = Game.create! :name => game_name, :player_count => 0
  puts 'New game created: ' << game.name
}


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
