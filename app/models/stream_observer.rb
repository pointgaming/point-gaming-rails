class StreamObserver < Mongoid::Observer
  def after_update(record)
    BunnyClient.instance.publish_fanout("c.s.#{record.id}", {
      :action => :stream_updated, 
      :stream => record,
      :bet_details => record.bet_details
    }.to_json)
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("c.s.#{record.id}", {
      :action => :stream_destroyed, 
      :stream => record
    }.to_json)
  end
end
