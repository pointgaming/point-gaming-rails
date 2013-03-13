class MatchObserver < Mongoid::Observer
  include MatchesHelper

  def after_create(record)
    BunnyClient.instance.publish_fanout("c.#{record.room.mq_exchange}", {
      :action => 'Match.new',
      :data => {
        :match => record,
        :match_details => match_details(record)
      }
    }.to_json)
  end

  def after_update(record)
    BunnyClient.instance.publish_fanout("c.#{record.room.mq_exchange}", {
      :action => 'Match.update',
      :data => {
        :match => record,
        :match_details => match_details(record)
      }
    }.to_json)
  end
end
