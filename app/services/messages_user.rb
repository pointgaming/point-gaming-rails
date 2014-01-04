class MessagesUser
  attr_reader :user, :message, :messenger

  def initialize(opts)
    @user = opts.fetch(:user)
    @message = opts.fetch(:message)
    @messenger = opts[:messenger] || BunnyWrapper
  end

  def send
    messenger.publish_fanout(exchange_name, message)
  end

  private

  def exchange_name
    "u.#{user._id}"
  end

end
