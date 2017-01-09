require 'active_support/core_ext/hash/keys'

require 'mt/data_api/client/endpoint_manager'
require 'mt/data_api/client/version'

module MT
  module DataAPI
    # Movable Type Data API client for Ruby.
    class Client
      attr_accessor :access_token

      def initialize(opts)
        opts = opts.symbolize_keys
        @access_token = opts.delete(:access_token)
        @endpoint_manager = EndpointManager.new(opts)
      end

      def call(id, args = {})
        id = id.to_s
        endpoint = @endpoint_manager.find_endpoint(id)
        return nil unless endpoint
        res = endpoint.call(@access_token, args)
        @access_token = res['accessToken'] if id == 'authenticate'
        @endpoint_manager.endpoints = res['items'] if id == 'list_endpoints'
        block_given? ? yield(res) : res
      end

      def endpoints
        @endpoint_manager.endpoints
      end
    end
  end
end
