require 'devise/strategies/token_authenticatable'

module Devise
  module Strategies
    class MultiTokenAuthenticatable < TokenAuthenticatable
      
    end
  end
end

Warden::Strategies.add(:multi_token_authenticatable, Devise::Strategies::MultiTokenAuthenticatable)
