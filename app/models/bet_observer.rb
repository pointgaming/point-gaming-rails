class BetObserver < Mongoid::Observer
  include Rails.application.routes.url_helpers

  def after_create(record)
    BunnyClient.instance.publish_fanout("c.s.#{record.stream.id}", {
      :action => :bet_created, 
      :bet => record, 
      :bookie => record.bookie, 
      :bet_path => user_stream_bet_path(record.stream, record)
    }.to_json)
  end

  def after_update(record)
    if record.bettor_id_changed? && record.bettor
      BunnyClient.instance.publish_fanout("c.s.#{record.stream.id}", {
        :action => :new_bettor, 
        :bet => record, 
        :bookie => record.bookie, 
        :bettor => record.bettor
      }.to_json)
    end
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("c.s.#{record.stream.id}", {
      :action => :bet_destroyed, 
      :bet => record
    }.to_json)
  end
end
