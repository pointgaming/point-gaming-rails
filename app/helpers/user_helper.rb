module UserHelper

  def reputation_tooltip(user)
    tags = []
    [:match_participation_count, :dispute_won_count, :dispute_lost_count].each do |key|
      tags << content_tag(:li, "#{User.human_attribute_name(key)}: #{user.send(key)}")
    end
    content_tag :ul, tags.join
  end

  def reputation_progress_class(reputation)
    case reputation
    when 99..100
      "progress-success"
    when 95..98
      "progress-info"
    when 90..94
      "progress-warning"
    else
      "progress-danger"
    end
  end

end
