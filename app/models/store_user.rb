class StoreUser < ActiveResource::Base
  include ActiveResource::Extend::AuthWithApi

  self.site = APP_CONFIG['store_api_url']
  self.element_name = 'user'

  self.api_key = APP_CONFIG['store_api_auth_token']
end
