module Store
  class Order < ::ActiveResource::Base
    include ::ActiveResource::Extend::AuthWithApi

    self.site = ::APP_CONFIG['store_api_url']
    self.element_name = 'order'

    self.api_key = ::APP_CONFIG['store_api_auth_token']

    def description
      line_items = []
      products.each do |product|
        line_items << product.name
      end
      line_items.join("<br />")
    end

  end
end
