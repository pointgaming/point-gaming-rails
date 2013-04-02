class VoidBetsJob
  @queue = :high

  def self.perform(value)
    match = Match.find(value)

    Bet.for_match(match).ne(match_hash: match.match_hash).pending.all.each do |bet|
      bet.update_attribute(:outcome, :void)
    end
  end

end
