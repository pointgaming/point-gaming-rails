class ForumUser < ActiveResource::Base
  include ActiveResource::Extend::AuthWithApi

  self.site = APP_CONFIG['forum_api_url']
  self.element_name = 'user'

  self.api_key = APP_CONFIG['forum_api_auth_token']
end
