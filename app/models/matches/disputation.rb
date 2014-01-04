require 'active_support/concern'

module Matches
  module Disputation
    extend ActiveSupport::Concern

    included do
      has_many :disputes
    end

    def dispute
      disputes.available.first
    end

    def is_disputable?
      self.state === 'finalized' && DateTime.now <= 48.hours.since(finalized_at)
    end

    def can_be_disputed_by?(user)
      return true if includes_bet_participant?(user)
      can_user_assign_cheater?(user)
    end
  end 
end