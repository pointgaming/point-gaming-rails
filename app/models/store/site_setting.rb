module Store
  class SiteSetting < ::ActiveResource::Base
    include ::ActiveResource::Extend::AuthWithApi

    self.site = ::APP_CONFIG['store_api_url']
    self.element_name = 'site_setting'

    self.api_key = ::APP_CONFIG['store_api_auth_token']
  end
end
