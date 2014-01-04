require 'active_support/concern'

module Services
  module Resque
    extend ActiveSupport::Concern

    protected

      def resque_available?
        defined?(::Resque) && ::Resque.keys ? true : false
      rescue Redis::CannotConnectError
        false
      end
  end
end