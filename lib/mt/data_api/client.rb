require 'active_support/core_ext/hash/keys'

require 'mt/data_api/client/endpoint_manager'
require 'mt/data_api/client/version'

module MT
  module DataAPI
    # Movable Type Data API client for Ruby.
    class Client
      attr_accessor :access_token

      def initialize(opts)
        opts_sym = opts.symbolize_keys
        unless opts_sym.key?(:client_id)
          opts_sym[:client_id] = default_client_id
        end
        @access_token = opts_sym.delete(:access_token)
        @endpoint_manager = EndpointManager.new(opts_sym)
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

      private

      def default_client_id
        'mt-data_api-client version ' + VERSION
      end
    end
  end
end
