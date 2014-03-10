module GamesHelper

  def link_to_lobby(display, game, options = {})
    link_to display, game.url, options.merge!(:class => 'requires-desktop-client', :'data-action' => 'joinLobby')
  end

end
