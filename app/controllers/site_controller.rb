# This class does not extend from ApplicationController because it's currently
# configured with before_filter authenticate_user!
class SiteController < ActionController::Base

  def desktop_version
    version = SiteSetting.find_by(key: 'desktop_version')
    render json: {version: version.value}
  rescue Mongoid::Errors::DocumentNotFound
    render json: {}, status: 404
  end

end
