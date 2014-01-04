puts "Setting up default games:"

Game.destroy_all

games = [
  "Quake Live",
  "Counter-Strike (All Versions)"
]

games.each {|game_name| 
  game = Game.create! name: game_name, player_count: 0
  puts "New game created: " << game.name
}

puts "Setting up default groups."

Group.destroy_all

groups = [
  {name: "CEO/COO", prefix: "~"},
  {name: "Executive", prefix: "@"},
  {name: "Super Admin", prefix: "#"},
  {name: "Admin", prefix: "$"},
  {name: "Dispute Admin", prefix: "%"},
  {name: "Forums Admin", prefix: "^"},
  {name: "Forums Moderator", prefix: "&"}
]

groups.each_with_index {|group, index| 
  group["sort_order"] = index unless group.has_key?(:sort_order)
  Group.create! group
}
