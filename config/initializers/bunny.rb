require "bunny"
require "singleton"

class BunnyClient
  include Singleton

  def publish_fanout(exchange, message)
    @bunny ||= setup_bunny
    x = @bunny.create_channel
    ch = x.fanout(exchange, {durable: true})
    ch.publish(message)
    puts "Publishing message: #{message} to exchange: #{exchange}"
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
