module TournamentsHelper
  def current_player
    @current_player ||= @tournament.player_for_user(current_user)
  end

  def widget(partial)
    render "tournaments/widgets/#{partial}"
  end
end
