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
  'Counter-Strike: Source'
]
games.each {|game_name| 
  game = Game.create! :name => game_name, :player_count => 0
  puts 'New game created: ' << game.name

  100.times { |i|
    game.rooms.create!({:description => "Room #{i}"})
  }
}
