require 'active_support/concern'

module Betting
  module PlayerBetting
    extend ActiveSupport::Concern

    protected

      def check_offering_user_points
        return unless offerer_wager.present?
      	pending_points = pending_user_points(offerer)
      	if offerer_wager > (offerer.points - pending_points)
      	  errors.add(:offerer_wager, "cannot be larger than your available points.") 
      	end
      end

      def check_taking_user_points
      	pending_points = pending_user_points(taker)
        if taker_wager > (taker.points - pending_points)
          errors.add(:taker_wager, "cannot be larger than your available points.") 
        end
      end    

      def accept_user_bet(user)
        self.outcome = 'accepted'
        self.taker = user
        self.taker_choice = user
        self.match.player_2 = user
      end

    private

      def pending_user_points(user)
        pending_points = Bet.pending.for_offerer(user).sum(:offerer_wager).to_i
        pending_points += Bet.pending.for_taker(user).sum(:taker_wager).to_i
      end
  end
end
