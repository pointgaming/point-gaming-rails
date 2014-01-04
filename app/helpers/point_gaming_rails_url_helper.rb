module PointGamingRailsUrlHelper

  def main_app_user_asset_url(path_to_file)
    "#{APP_CONFIG['main_app_url']}#{path_to_file.gsub(/^\//, '')}"
  end

  def bet_url(bet)
    "#{APP_CONFIG['main_app_url']}bet_history/#{bet._id}"
  end

  def dispute_url(dispute)
    "#{APP_CONFIG['main_app_url']}disputes/#{dispute._id}"
  end

  def stream_url(slug)
    "#{APP_CONFIG['main_app_url'].gsub(/^https:/, 'http:')}s/#{slug}"
  end

  def match_url(match)
    "#{APP_CONFIG['main_app_url']}matches/#{match._id}"
  end

  def order_url(order)
    "#{APP_CONFIG['main_app_url']}orders/#{order._id}"
  end

  def store_order_url(order)
    "#{APP_CONFIG['store_url']}orders/#{order.number}"
  end

  def user_url(user)
    "#{APP_CONFIG['main_app_url']}u/#{user.slug}"
  end

  def subscriptions_url
    "#{APP_CONFIG['main_app_url']}subscriptions"
  end

  def tournament_players_url(tournament)
    "#{APP_CONFIG['main_app_url']}tournaments/#{tournament._id}"
  end

  def tournament_player_url(tournament, user)
    "#{APP_CONFIG['main_app_url']}tournaments/#{tournament._id}/players/#{user._id}"
  end

  def user_account_balance_url(user)
    "#{APP_CONFIG['main_app_url']}u/#{user.slug}/account_balance"
  end

  def user_tournament_url(tournament)
    "#{APP_CONFIG['main_app_url']}user_tournaments/#{tournament._id}"
  end

end
