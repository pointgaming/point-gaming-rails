module TournamentsHelper
  def current_player
    @current_player ||= @tournament.player_for_user(current_user)
  end

  def widget(partial)
    render "tournaments/widgets/#{partial}"
  end

  def currently_playing?
    @currently_playing ||= @tournament.started? && @tournament.checked_in?(current_user)
  end

  def friendly_placement(placed)
    suffixify = lambda { |p|
      suffixes = [nil, "st", "nd", "rd"]
      mod = p % 10
      if suffix = suffixes[mod]
        "#{p}#{suffix}"
      else
        "#{p}th"
      end
    }

    if placed <= 4
      suffixify.call(placed)
    else
      "#{suffixify.call(placed)}/#{suffixify.call((placed - 1) * 2)}"
    end
  end
end
