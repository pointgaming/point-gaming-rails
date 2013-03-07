class BetObserver < Mongoid::Observer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include StreamsHelper

  def after_create(record)
    BunnyClient.instance.publish_fanout("c.#{record.room.mq_exchange}", {
      :action => 'Bet.new',
      :data => {
        :bet => record.as_json(:include => [:bookie]),
        :bet_tooltip => bet_tooltip(record),
        :bet_path => polymorphic_path([record.room, record])
      }
    }.to_json)
  end

  def after_update(record)
    if record.bettor_id_changed? && record.bettor
      BunnyClient.instance.publish_fanout("c.#{record.room.mq_exchange}", {
        :action => 'Bet.Bettor.new', 
        :data => {
          :bet => record, 
          :bookie => record.bookie, 
          :bettor => record.bettor
        }
      }.to_json)
    end
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("c.#{record.room.mq_exchange}", {
      :action => 'Bet.destroy', 
      :data => {
        :bet => record
      }
    }.to_json)
  end
end
