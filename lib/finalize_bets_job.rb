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
        if bet.taker_id.nil?
          bet.update_attribute(:outcome, :void)
        elsif bet.offerer_choice_id === match.winner_id && bet.offerer_choice_type === match.winner_type
          bet.update_attribute(:outcome, :offerer_won)

          bet.taker.transfer_points_to_user(bet.offerer, bet.taker_wager)
          bet.offerer.inc(:finalized_bets_count, 1)
          bet.taker.inc(:finalized_bets_count, 1)
        else
          bet.update_attribute(:outcome, :taker_won)

          bet.offerer.transfer_points_to_user(bet.taker, bet.offerer_wager)
          bet.taker.inc(:finalized_bets_count, 1)
          bet.offerer.inc(:finalized_bets_count, 1)
        end
      }
    elsif match.state === 'cancelled'
      lambda {|bet| bet.update_attribute(:outcome, :cancelled) }
    else
      raise "Invalid match state for finalizing bets"
    end
  end
end
