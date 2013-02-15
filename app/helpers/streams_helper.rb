module StreamsHelper
  def bet_tooltip(bet)
    tags = []
    bet.tooltip_attributes.each do |key|
      tags << content_tag(:li, "#{Bet.human_attribute_name(key)}: #{bet.send(key)}")
    end
    "Player #{bet.bookie.try(:username)} thinks: #{content_tag :ul, tags.join}"
  end
end
