module BunnyWrapper
  extend self

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger ||= nil
  end

  def log(severity, message)
    logger.send(severity, message) if logger
  end

  def publish_fanout(exchange_name, message)
    channel = bunny.create_channel
    exchange = channel.fanout(exchange_name, {durable: true})
    exchange.publish(message)
    channel.close

    log :info, "Publishing message: #{message} to exchange: #{exchange_name}"
  rescue => e
    log :error, "Publishing error: #{message} to exchange: #{exchange_name}. ERROR: #{e.message}"
  end

  def bunny
    @bunny ||= setup_bunny
  end

  def setup_bunny
    bunny = Bunny.new
    bunny.start
    bunny
  end

end
