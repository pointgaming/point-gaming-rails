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

  def markdown(details)
    @html_renderer  ||= Redcarpet::Render::HTML.new(filter_html: true,
                                                    hard_wrap: true,
                                                    link_attributes: { target: "_blank" })

    @renderer       ||= Redcarpet::Markdown.new(@html_renderer,
                                                no_intra_emphasis: true,
                                                autolink: true,
                                                tables: true,
                                                strikethrough: true,
                                                superscript: true,
                                                underline: true,
                                                prettify: true,
                                                highlight: true)

    @renderer.render(details).gsub("<table>", "<table class='table table-striped table-bordered'>").html_safe
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
