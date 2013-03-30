module GamesHelper
  def game_css_class(game)
    game.nil? ? '' : game.name.gsub(/[^\w]/, '')
  end
end
