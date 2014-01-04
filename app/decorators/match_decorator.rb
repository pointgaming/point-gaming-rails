class MatchDecorator < Draper::Decorator

  def details(format = :long)
    case format
    when :long
      "#{status}: #{model.player_1.display_name} vs #{player_2_name} on #{model.map}"
    when :short
      "#{model.player_1.display_name} vs #{player_2_name} on #{model.map}"
    else
      raise 'Invalid format'
    end
  end

  def status
    if model.state === 'new'
      "New Match"
    else
      "Match #{model.state.capitalize}"
    end
  end

  private

    def player_2_name
      model && model.player_2 ? model.player_2.display_name : "--"
    end
end
