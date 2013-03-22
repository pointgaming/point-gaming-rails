module MatchesHelper
  def match_details(match, format=:long)
    return "" unless match

    case format
    when :long
      "#{match_status(match.state)}: #{match.player_1.display_name} vs #{match.player_2.display_name} on #{match.map}"
    when :short
      "#{match.player_1.display_name} vs #{match.player_2.display_name} on #{match.map}"
    else
      raise 'Invalid format'
    end
  end

  def match_status(state)
    if state === 'new'
      "New Match"
    else
      "Match #{state.capitalize}"
    end
  end
end
