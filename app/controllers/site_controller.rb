class SiteController < ApplicationController

  def desktop_version
    version = SiteSetting.find_by(key: 'desktop_version')
    render json: {version: version.value}
  rescue Mongoid::Errors::DocumentNotFound
    render json: {}, status: 404
  end

  def leaderboard
    @players = User.order_by(points: :desc).all
    @teams = Team.order_by(points: :desc).all
  end

  # prevent authenticate_user! from running before the desktop_version action
  def requested_public_url?
    request.env['PATH_INFO'].ends_with?('/desktop_client/version')
  end
end
