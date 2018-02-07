require 'spec_helper.rb'

require 'json'
require 'net/http'
require 'uri'

require 'active_support/core_ext/hash/keys'
require 'webmock/rspec'

require 'mt/data_api/client/endpoint'

describe MT::DataAPI::Client::Endpoint do
  list_endpoints_hash = {
    id: 'list_endpoints',
    route: '/endpoints',
    version: 1,
    verb: 'GET'
  }
  api_url = 'http://localhost/mt/mt-data-api.cgi/v3'
  client_id = 'mt-data_api-client'

  before(:all) do
    described_class.api_url = api_url
    described_class.client_id = client_id
  end

  describe '#initialize' do
    shared_examples_for :instance do
      it "is an instance of #{described_class}" do
        expect(endpoint).to be_instance_of(MT::DataAPI::Client::Endpoint)
      end
      it 'has "list_endpoints" as @id' do
        expect(endpoint.instance_variable_get(:@id)).to eq('list_endpoints')
      end
      it 'has "/endpoints" as @route' do
        expect(endpoint.instance_variable_get(:@route)).to eq('/endpoints')
      end
      it 'has 1 as @version' do
        expect(endpoint.instance_variable_get(:@version)).to eq(1)
      end
      it 'has "GET" as verb' do
        expect(endpoint.verb).to eq('GET')
      end
    end

    context 'with endpoint hash' do
      let(:endpoint) { described_class.new(list_endpoints_hash) }
      it_behaves_like :instance
    end

    context 'with string key hash' do
      let(:endpoint) { described_class.new(list_endpoints_hash.stringify_keys) }
      it_behaves_like :instance
    end

    context 'with not hash' do
      it 'raises ArgumentError' do
        expect { described_class.new(1) }.to raise_error(ArgumentError)
      end
    end

    context 'with invalid verb' do
      it 'raises ArgumentError' do
        invalid_hash = {
          id: 'test',
          route: '/test',
          version: 1,
          verb: 'INVALID'
        }
        expect { described_class.new(invalid_hash) }.to \
          raise_error(ArgumentError)
      end
    end
  end

  describe '#call' do
    after(:each) { WebMock.reset! }

    context 'with valid reponse' do
      it 'returns parsed json' do
        stub_request(:get, "#{api_url}/endpoints").to_return(body: {}.to_json)
        endpoint = described_class.new(list_endpoints_hash)
        expect(endpoint.call).to eq({})
      end
    end

    context 'with invalid response' do
      it 'returns error' do
        stub_request(:get, "#{api_url}/endpoints")\
          .to_return(status: [500, 'Internal Server Error'])
        endpoint = described_class.new(list_endpoints_hash)
        expect(endpoint.call).to be_nil
      end
    end

    context 'to authenticate endpoint' do
      authenticate_endpoint_hash = {
        id: 'authenticate',
        route: '/authentication',
        version: 1,
        verb: 'POST'
      }
      it 'includes clientId in parameter' do
        stub_request(:post, "#{api_url}/authentication")
          .with(body: {
            username: 'admin',
            password: 'password',
            clientId: client_id,
          })
        endpoint = described_class.new(authenticate_endpoint_hash)
        endpoint.call('dummy_access_token', {
          username: 'admin',
          password: 'password'
        })
      end
    end

    context 'to authorize endpoint' do
      authorize_endpoint_hash = {
        id: 'authorize',
        route: '/authorization',
        version: 1,
        verb: 'GET'
      }
      it 'includes clientId in parameter' do
        stub_request(:get, "#{api_url}/authorization")
          .with(query: {
            redirectUrl: 'http://example.com',
            clientId: client_id,
          })
        endpoint = described_class.new(authorize_endpoint_hash)
        endpoint.call('dummy_access_token', {
          redirectUrl: 'http://example.com'
        })
      end
    end
  end

  describe '#request_url' do
    list_entries_hash = {
      id: 'list_entries',
      route: '/sites/:site_id/entries',
      version: 1,
      verb: 'GET'
    }

    context 'with no parameter route' do
      it 'returns api_url and route' do
        endpoint = described_class.new(list_endpoints_hash)
        args = {}
        expected = described_class.instance_variable_get(:@api_url) \
          + list_endpoints_hash[:route]
        expect(endpoint.request_url(args)).to eq(expected)
      end
    end

    context 'with parameter route' do
      it 'returns api_url and replaced route' do
        endpoint = described_class.new(list_entries_hash)
        args = { site_id: 1 }
        expected = described_class.instance_variable_get(:@api_url) \
          + '/sites/1/entries'
        expect(endpoint.request_url(args)).to eq(expected)
      end
    end

    context 'with parameter route and no parameter' do
      it 'raises ArgumentError' do
        endpoint = described_class.new(list_entries_hash)
        args = {}
        expect { endpoint.request_url(args) }.to raise_error(ArgumentError)
      end
    end

    context 'with query and GET method' do
      it 'returns api_url, route and query string' do
        endpoint = described_class.new(list_endpoints_hash)
        args = { limit: 1, offset: 2 }
        expected = described_class.instance_variable_get(:@api_url) \
          + list_endpoints_hash[:route] + '?limit=1&offset=2'
        expect(endpoint.request_url(args)).to eq(expected)
      end
    end

    context 'with query and not GET method' do
      it 'returns api_url and route' do
        hash = {
          id: 'post',
          route: '/post',
          version: 1,
          verb: 'POST'
        }
        endpoint = described_class.new(hash)
        args = { limit: 1, offset: 2 }
        expected = described_class.instance_variable_get(:@api_url) \
          + hash[:route]
        expect(endpoint.request_url(args)).to eq(expected)
      end
    end
  end
end
