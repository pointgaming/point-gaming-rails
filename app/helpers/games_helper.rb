module GamesHelper
  def game_css_class(game)
    game.nil? ? '' : game.name.gsub(/[^\w]/, '')
  end

  def link_to_lobby(game, options={})
    link_to game.display_name, game.url, options.merge!(:class => 'requires-desktop-client', :'data-action' => 'joinLobby')
  end
end
