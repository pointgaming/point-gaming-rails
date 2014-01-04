require 'active_support/concern'

module Matches
  module MatchPublication
    extend ActiveSupport::Concern

    included do
  	  after_create :publish_created
  	  after_update :publish_updated
    end

    protected

      def can_publish_message?
        room.present?
      end

    private

    def publish_created
      return unless can_publish_message?
      BunnyWrapper.publish_fanout("c.#{self.room.mq_exchange}", {
        :action => 'Match.new',
        :data => {
          :match => self.as_json(:methods => [:room]),
          :match_details => decorate.details
        }
      }.to_json)
    end

    def publish_updated
      return unless can_publish_message?
      BunnyWrapper.publish_fanout("c.#{self.room.mq_exchange}", {
        :action => 'Match.update',
        :data => {
          :match => self.as_json(:methods => [:room]),
          :match_details => decorate.details
        }
      }.to_json)
    end
  end
end