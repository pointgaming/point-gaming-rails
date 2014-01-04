module UrlHelper

  def main_app_path
    APP_CONFIG['main_app_url']
  end

  def forum_path
    APP_CONFIG['forum_url']
  end

  def store_path
    APP_CONFIG['store_url']
  end

  def admin_path
    APP_CONFIG['admin_url']
  end

  def new_user_session_path
    APP_CONFIG['login_url']
  end

  def destroy_user_session_path
    APP_CONFIG['logout_url']
  end

end
