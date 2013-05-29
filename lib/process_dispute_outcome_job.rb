class ProcessDisputeOutcomeJob
  @queue = :high

  def self.perform(value)
    dispute = Dispute.find(value)

    update_match(dispute)
    update_bets(dispute)
  end

  def self.update_match(dispute)
    match_log = dispute.match_logs.build({original: dispute.match.attributes.dup, action: dispute.outcome})
    if dispute.outcome === 'new_match_winner'
      raise "dispute.winner required when dispute.outcome is :new_match_winner" unless dispute.winner.present?

      dispute.match.winner = dispute.winner
      raise "Failed to save or finalize_dispute match" unless dispute.match.save && dispute.match.dispute_finalized!
    elsif dispute.outcome === 'void_match'
      dispute.match.winner = nil
      raise "Failed to save or finalize_dispute match" unless dispute.match.save && dispute.match.dispute_finalized!
    else
      raise "Invalid dispute.outcome"
    end
    match_log.modified = dispute.match.attributes.dup
    match_log.save
  end

  def self.update_bets(dispute)
    bet_finalizer = get_bet_finalizer(dispute)

    if dispute.outcome === 'new_match_winner'
      Bet.for_match(dispute.match).
          any_of({outcome: :offerer_won, taker_choice_id: dispute.winner_id, taker_choice_type: dispute.winner_type}, 
                 {outcome: :taker_won, offerer_choice_id: dispute.winner_id, offerer_choice_type: dispute.winner_type}).
          all.each &bet_finalizer
    elsif dispute.outcome === 'void_match'
      Bet.for_match(dispute.match).in(outcome: [:taker_won, :offerer_won]).all.each &bet_finalizer
    end
  end

  def self.get_bet_finalizer(dispute)
    if dispute.outcome === 'new_match_winner'
      lambda {|bet| 
        if bet.outcome === 'taker_won' && bet.offerer_choice_id === dispute.winner_id && bet.offerer_choice_type === dispute.winner_type
          bet.update_attribute(:outcome, :offerer_won)
          bet.taker.transfer_points_to_user(bet.offerer, bet.offerer_wager + bet.taker_wager)
        elsif bet.outcome === 'offerer_won' && bet.taker_choice_id === dispute.winner_id && bet.taker_choice_type === dispute.winner_type
          bet.update_attribute(:outcome, :taker_won)
          bet.offerer.transfer_points_to_user(bet.taker, bet.taker_wager + bet.offerer_wager)
        end
      }
    elsif dispute.outcome === 'void_match'
      lambda {|bet|
        original_outcome = bet.outcome
        bet.update_attribute(:outcome, :void)
        Resque.enqueue RecalculateUserMatchesParticipatedInCountJob, bet.offerer._id
        Resque.enqueue RecalculateUserMatchesParticipatedInCountJob, bet.taker._id
        if original_outcome === 'taker_won'
          bet.taker.transfer_points_to_user(bet.offerer, bet.offerer_wager)
        elsif original_outcome === 'offerer_won'
          bet.offerer.transfer_points_to_user(bet.taker, bet.taker_wager)
        end
      }
    else
      raise "Invalid dispute outcome for processing: #{dispute.outcome}"
    end
  end
end
