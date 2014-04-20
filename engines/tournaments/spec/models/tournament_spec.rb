require "spec_helper"

describe Tournament do
  before(:each) do
    @tournament = Fabricate.build(:tournament)
    @tournament.save

    @usernames ||= [
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
    ]

    @usernames.each_with_index do |username, i|
      user = Fabricate.build(:user, username: username)
      user.save

      @tournament.players.create(user: user, seed: i).check_in!
    end
  end

  it "should traverse brackets" do
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
      @tournament.report_scores_for!(user, *scores).should eq(true)
    end

    {
      "fazz"    => [3,0],
      "k1llsen" => [3,0],
      "Gienon"  => [3,0],
      "FraZe"   => [3,1]
    }.each do |user, scores|
      @tournament.report_scores_for!(user, *scores).should eq(true)
    end

    {
      "rapha"   => [3,0],
      "evil"    => [3,0],
      "Spart1e" => [3,0],
      "Av3k"    => [3,1]
    }.each do |user, scores|
      @tournament.report_scores_for!(user, *scores).should eq(true)
    end

    {
      "rapha"   => [3,2],
      "Av3k"    => [3,2]
    }.each do |user, scores|
      @tournament.report_scores_for!(user, *scores).should eq(true)
    end

    @tournament.report_scores_for!("fazz",   3, 0).should eq(true)
    @tournament.report_scores_for!("Cypher", 3, 0).should eq(true)
    @tournament.report_scores_for!("FraZe",  3, 0).should eq(true)
    @tournament.report_scores_for!("Cypher", 3, 0).should eq(true)
    @tournament.report_scores_for!("DaHanG", 3, 0).should eq(true)
    @tournament.report_scores_for!("Cypher", 3, 0).should eq(true)
    @tournament.report_scores_for!("DaHanG", 3, 0).should eq(true)
    @tournament.report_scores_for!("evil",   3, 0).should eq(true)
    @tournament.report_scores_for!("rapha",  3, 0).should eq(true)
    @tournament.report_scores_for!("evil",   3, 0).should eq(true)
    @tournament.report_scores_for!("evil",   3, 0).should eq(true)
    @tournament.report_scores_for!("Cypher", 3, 0).should eq(true)
    @tournament.report_scores_for!("rapha",  3, 0).should eq(true)
  end

  @tournament.ended?.should eq(true)
  @tournament.player_for_user("rapha").placed.should   eq(1)
  @tournament.player_for_user("evil").placed.should    eq(2)
  @tournament.player_for_user("Cypher").placed.should  eq(3)
  @tournament.player_for_user("Av3k").placed.should    eq(4)
end
