require 'devise/models/token_authenticatable'

module Devise
  module Models
    module MultiTokenAuthenticatable
      extend ActiveSupport::Concern

      # Hook called after token authentication.
      def after_token_authentication
      end

      module ClassMethods
        def find_for_token_authentication(conditions)
          begin
            token = AuthToken.find conditions[token_authentication_key]
            token.user unless token.nil?
          rescue Mongoid::Errors::DocumentNotFound
            nil
          end
        end

        Devise::Models.config(self, :token_authentication_key)
      end
    end
  end
end
