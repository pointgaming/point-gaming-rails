module StreamsHelper
  def bet_tooltip(bet, user)
    tags = []
    [:risk_amount, :win_amount].each do |key|
      tags << content_tag(:li, "#{Bet.human_attribute_name(key)}: #{bet.send(key, user)}")
    end
    content_tag :ul, tags.join
  end
end
