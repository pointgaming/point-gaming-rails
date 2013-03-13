class StreamObserver < Mongoid::Observer

  def after_update(record)
    BunnyClient.instance.publish_fanout("c.#{record.mq_exchange}", {
      :action => 'Stream.update',
      :data => {
        :stream => record
      }
    }.to_json)
  end

  def after_destroy(record)
    BunnyClient.instance.publish_fanout("c.#{record.mq_exchange}", {
      :action => 'Stream.destroy',
      :data => {
        :stream => record
      }
    }.to_json)
  end
end
