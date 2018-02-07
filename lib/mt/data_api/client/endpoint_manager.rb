require 'active_support/core_ext/hash/keys'

require 'mt/data_api/client/endpoint'

module MT
  module DataAPI
    class Client
      # Retrieve and find endpoints
      class EndpointManager
        DEFAULT_API_VERSION = 3
        LIST_ENDPOINTS_HASH = {
          'id' => 'list_endpoints',
          'route' => '/endpoints',
          'version' => 1,
          'verb' => 'GET'
        }.freeze

        attr_accessor :endpoints

        def initialize(opts)
          raise parameter_should_be_hash unless opts.is_a? Hash
          initialize_parameters(opts.symbolize_keys)
          raise invalid_parameter unless @base_url && @client_id
          Endpoint.api_url = api_url
          Endpoint.client_id = @client_id
        end

        def find_endpoint(id)
          hash = find_endpoint_hash(id)
          hash ? Endpoint.new(hash) : nil
        end

        private

        def initialize_parameters(opts)
          @base_url = opts[:base_url]
          @client_id = opts[:client_id]
          @api_version = opts[:api_version] || DEFAULT_API_VERSION
          @endpoints = opts[:endpoints] if opts.key? :endpoints
        end

        def parameter_should_be_hash
          ArgumentError.new 'parameter should be hash'
        end

        def invalid_parameter
          ArgumentError.new 'parameter "base_url" and "client_id" are required'
        end

        def find_endpoint_hash(id)
          @endpoints ||= retrieve_endpoints
          endpoints = @endpoints.select do |ep|
            ep['id'].to_s == id.to_s && @api_version.to_i >= ep['version'].to_i
          end
          endpoints.first
        end

        def api_url
          url = @base_url
          url += '/' unless url[-1] == '/'
          url + 'v' + @api_version.to_s
        end

        def retrieve_endpoints
          response = Endpoint.new(LIST_ENDPOINTS_HASH).call
          raise response['error'] if response.key? 'error'
          endpoints = response['items']
          endpoints.sort { |a, b| b['version'].to_i <=> a['version'].to_i }
        end
      end
    end
  end
end
