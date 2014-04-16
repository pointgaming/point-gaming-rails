task :fake_tournament => :environment do
  tournament = Tournament.last
  tournament.players.destroy_all

  [
    "rapha",
    "DaHanG",
    "Tox",
    "evil",
    "Cypher",
    "Spart1e",
    "Av3k",
    "dem0n",
    "Plazmaistar",
    "kRoNic",
    "FraZe",
    "etty",
    "k1llsen",
    "Twister",
    "Gienon",
    "fazz"
  ].each_with_index do |username, i|
    user = User.find_by(username: username) rescue nil

    if user.nil?
      user = User.create!(username: username, email: "#{username.downcase}@gmail.com",
                          first_name: username, last_name: "Derpina",
                          password: "watwat", password_confirmation: "watwat",
                          phone: "(972) 555-4444", points: 500, country: "Murica",
                          registration_pin: "1337")
    end

    tournament.players.create(user: user, seed: i).check_in!
  end

  {
    "rapha"   => [3,0],
    "DaHanG"  => [3,0],
    "Tox"     => [3,0],
    "evil"    => [3,0],
    "Cypher"  => [3,0],
    "Spart1e" => [3,1],
    "Av3k"    => [3,0],
    "dem0n"   => [3,0]
  }.each do |user, scores|
    tournament.report_scores_for!(user, *scores)
  end

  {
    "fazz"    => [3,0],
    "k1llsen" => [3,0],
    "Gienon"  => [3,0],
    "FraZe"   => [3,1]
  }.each do |user, scores|
    tournament.report_scores_for!(user, *scores)
  end

  {
    "rapha"   => [3,0],
    "evil"    => [3,0],
    "Spart1e" => [3,0],
    "Av3k"    => [3,1]
  }.each do |user, scores|
    tournament.report_scores_for!(user, *scores)
  end

  {
    "rapha"   => [3,2],
    "Av3k"    => [3,2]
  }.each do |user, scores|
    tournament.report_scores_for!(user, *scores)
  end

  tournament.report_scores_for!("fazz",   3, 0)
  tournament.report_scores_for!("Cypher", 3, 0)
  tournament.report_scores_for!("FraZe",  3, 0)
end
