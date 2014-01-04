require 'active_support/concern'

module Betting
  module BetPublication
    extend ActiveSupport::Concern

    included do
	  after_create  :publish_bet_created
	  after_update  :publish_bet_updated
	  after_destroy :publish_bet_destroyed
    end

    protected

      def can_publish_message?
        match.present? && match.room.present?
      end

    private

      def publish_update_action
      	(taker_id_changed? && taker) ? 'Bet.Taker.new' : 'Bet.update'
      end

	  def publish_bet_created
	    return unless can_publish_message?

	    BunnyWrapper.publish_fanout("c.#{match.room.mq_exchange}", {
	      :action => 'Bet.new',
	      :data => {
	        :bet => self.as_json(:include => [:offerer]),
	        :bet_path => polymorphic_path([match, self])
	      }
	    }.to_json)
	  end

	  def publish_bet_updated
	    return unless can_publish_message?

	    BunnyWrapper.publish_fanout("c.#{match.room.mq_exchange}", {
	      :action => publish_update_action,
	      :data => {
	        :bet => self.as_json(:include => [:offerer, :taker])
	      }
	    }.to_json)
	  end

	  def publish_bet_destroyed
	    return unless can_publish_message?

	    BunnyWrapper.publish_fanout("c.#{match.room.mq_exchange}", {
	      :action => 'Bet.destroy', 
	      :data => {
	        :bet => self.as_json(:include => [:offerer, :taker])
	      }
	    }.to_json)
	  end
  end
end