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

    f = ActiveSupport::Inflector.ordinalize(placed)

    if placed <= 4
      f
    else
      l = ActiveSupport::Inflector.ordinalize((placed - 1) * 2)
      "#{f}/#{l}"
    end
  end
end
