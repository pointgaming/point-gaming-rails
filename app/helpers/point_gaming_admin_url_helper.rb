module PointGamingAdminUrlHelper

  def edit_admin_news_url(news)
    "#{APP_CONFIG['admin_url']}news/#{news._id}/edit"
  end

end
