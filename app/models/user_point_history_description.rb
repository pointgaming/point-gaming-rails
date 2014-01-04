class UserPointHistoryDescription

  def initialize(action_source)
    @action_source = action_source
  end

  def to_s
    description
  end

  private

  def description
    @description ||= build_description
  end

  def build_description
    case
    when @action_source.is_a?(Bet)
      match_description(@action_source.match)
    when @action_source.is_a?(Dispute)
      "Disputed: #{match_description(@action_source.match)}"
    when @action_source.is_a?(Subscription)
      "Points for Subscription"
    when @action_source.is_a?(Store::Order)
      "Point Kickback from Store Order"
    else
      @action_source.to_s
    end
  end

  private

  def match_description(match)
    match.present? ? match.decorate.details(:short) : ''
  end

end
