class SiteController < ApplicationController
  def desktop_version
    render json: {version: desktop_client_latest_version}
  end

  def leaderboard
    @players = User.order_by(points: :desc).all
    @teams = Team.order_by(points: :desc).all
  end

  def game_type_options
    game = Game.find params[:game_id] if params[:game_id].present?
    render partial: 'shared/game_type_select', locals: {model_name: params[:for], game: game}
  end

  # prevent authenticate_user! from running before the desktop_version action
  def requested_public_url?
    request.env['PATH_INFO'].ends_with?('/desktop_client/version')
  end
end
