require 'net/http'
require 'uri'

module MT
  module DataAPI
    class Client
      # Send request to endpoint
      class APIRequest
        def initialize(endpoint)
          @endpoint = endpoint
        end

        def send(access_token, args)
          uri = URI.parse(@endpoint.request_url(args))
          net_http(uri).start do |http|
            http.request(request(uri, access_token, args))
          end
        end

        private

        def net_http(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'
          http
        end

        def request(uri, access_token, args)
          req = http_request_class.new(uri)
          if access_token
            req['X-MT-Authorization'] = "MTAuth accessToken=#{access_token}"
          end
          set_form(req, args) if post_or_put?
          req
        end

        def contains_file_object?(args)
          args.values.any? { |v| file?(v) }
        end

        def file?(file)
          file.is_a?(File) && File.file?(file.path)
        end

        def http_request_class
          Object.const_get("Net::HTTP::#{@endpoint.verb.capitalize}")
        end

        def multipart_args(args)
          args.map do |k, v|
            if file?(v)
              [k.to_s, v, { filename: File.basename(v.path) }]
            else
              [k.to_s, v.to_s]
            end
          end
        end

        def post_or_put?
          %w[POST PUT].include? @endpoint.verb
        end

        def set_form(req, args)
          if contains_file_object?(args)
            req.set_form(multipart_args(args), 'multipart/form-data')
          else
            req.set_form_data(args)
          end
        end
      end
    end
  end
end
