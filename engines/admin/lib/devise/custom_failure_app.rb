class CustomFailureApp < Devise::FailureApp

  def redirect_url
    if warden_message == :timeout
      flash[:timedout] = true
      attempted_path || main_app_sign_in_url
    else
      main_app_sign_in_url
    end
  end

  def main_app_sign_in_url
    APP_CONFIG['login_url']
  end

end
