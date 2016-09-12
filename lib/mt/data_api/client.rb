require 'active_support/core_ext/hash/keys'

require 'mt/data_api/client/endpoint_manager'
require 'mt/data_api/client/version'

module MT
  module DataAPI
    # Movable Type Data API client for Ruby.
    class Client
      attr_reader :access_token

      def initialize(opts)
        opts = opts.symbolize_keys
        @access_token = opts.delete(:access_token)
        @endpoint_manager = EndpointManager.new(opts)
      end

      def call(id, args = {})
        endpoint = find_endpoint(id)
        res = endpoint.call(@access_token, args)
        @access_token = res['accessToken'] if id == 'authenticate'
        @endpoint_manager.endpoints = res['items'] if id == 'list_endpoints'
        res
      end

      def endpoints
        @endpoint_manager.endpoints
      end

      private

      def find_endpoint(id)
        endpoint = @endpoint_manager.find_endpoint(id.to_s)
        raise "no endpoint: #{id}" unless endpoint
        endpoint
      end
    end
  end
end
