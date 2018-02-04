require 'json'

require 'active_support/core_ext/hash/keys'

require 'mt/data_api/client/api_request'

module MT
  module DataAPI
    class Client
      # Send request to endpoint.
      class Endpoint
        class << self
          attr_writer :api_url
        end

        attr_reader :verb

        def initialize(hash)
          raise ArgumentError, 'parameter should be hash' unless hash.is_a? Hash
          hash = hash.symbolize_keys

          @id = hash[:id]
          @route = hash[:route]
          @version = hash[:version]
          @verb = hash[:verb]

          raise ArgumentError, "invalid verb: #{@verb}" unless valid_verb?
        end

        def call(access_token = nil, args = {})
          res = APIRequest.new(self).send(access_token, args)
          return nil if res.body.nil?
          JSON.parse(res.body)
        end

        def request_url(args)
          url = self.class.instance_variable_get(:@api_url) + route(args)
          url += query_string(args) if @verb == 'GET'
          url
        end

        private

        def route(args = {})
          route = @route.dup
          route.scan(%r{:[^:/]+(?=/|$)}).each do |m|
            key = m.sub(/^:/, '').to_sym
            value = args.delete(key)
            raise ArgumentError, %(parameter "#{key}" is required) unless value
            route.sub!(/#{m}/, value.to_s)
          end
          route
        end

        def query_string(args = {})
          return '' if args.empty?
          query = args.keys.sort.map do |key|
            [key, args[key]].join('=')
          end
          '?' + query.join('&')
        end

        def valid_verb?
          %w[GET POST PUT DELETE].include? @verb
        end
      end
    end
  end
end
