require 'rack/ssl'

module Rack
  class SSL

    private

    def flag_cookies_as_secure!(headers)
      # secure cookies should not be forced to support viewing the streams page
      # in http:// mode
    end

  end
end
