class FinalizeBetsJob
  @queue = :high

  def self.perform(value)
    match = Match.find(value)
    bet_finalizer = get_bet_finalizer(match)

    Bet.pending.for_match(match).all.each &bet_finalizer
  end

  def self.get_bet_finalizer(match)
    if match.state === 'finalized' && match.winner
      lambda {|bet| 
        if bet.bettor_id.nil?
          bet.update_attribute(:outcome, :void)
        elsif bet.winner._id === match.winner._id
          bet.update_attribute(:outcome, :bookie_won)

          bet.bookie.inc(:points, bet.amount)
          bet.bettor.inc(:points, bet.amount * -1)
        else
          bet.update_attribute(:outcome, :bettor_won)

          bet.bettor.inc(:points, bet.amount)
          bet.bookie.inc(:points, bet.amount * -1)
        end
      }
    elsif match.state === 'cancelled'
      lambda {|bet| bet.update_attribute(:outcome, :cancelled) }
    else
      raise "Invalid match state for finalizing bets"
    end
  end
end
