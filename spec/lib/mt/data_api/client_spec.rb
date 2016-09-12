require 'spec_helper.rb'

require 'json'

require 'webmock/rspec'

require 'mt/data_api/client'
require 'mt/data_api/client/endpoint_manager'

describe MT::DataAPI::Client do
  opts = {
    base_url: 'http://localhost/mt/mt-data-api.cgi',
    client_id: 'test'
  }

  endpoints = [MT::DataAPI::Client::EndpointManager::LIST_ENDPOINTS_HASH]
  opts_with_endpoints = opts.merge(endpoints: endpoints)

  describe '#initialize' do
    client = described_class.new(opts)

    it "returns an instance of #{described_class}" do
      expect(client).to be_instance_of(described_class)
    end
  end

  describe '#access_token' do
    context 'when access_token is set' do
      access_token = 'test_token'
      client = described_class.new(opts.merge(access_token: access_token))

      it 'returns set access_token' do
        expect(client.access_token).to eq(access_token)
      end
    end

    context 'when access_token is not set' do
      client = described_class.new(opts)

      it 'returns set access_token' do
        expect(client.access_token).to be_nil
      end
    end
  end

  describe '#call' do
    context 'when no endpoint' do
      client = described_class.new(opts_with_endpoints)

      it 'raises error' do
        id = 'invalid'
        expect { client.call(id) }.to raise_error("no endpoint: #{id}")
      end
    end

    context 'when endpoint is found' do
      api_version = MT::DataAPI::Client::EndpointManager::DEFAULT_API_VERSION

      context 'when list_endpoints' do
        url = opts[:base_url] + "/v#{api_version}" + endpoints[0]['route']
        expected_res = {
          'totalResults' => 1,
          'items' => endpoints
        }

        before(:each) do
          stub_request(:get, url).to_return(body: expected_res.to_json)
        end

        after(:each) { WebMock.reset! }

        shared_examples_for :list_endpoints do
          it 'returns JSON' do
            expect(@res).to eq(expected_res)
          end

          it 'has endpoints' do
            expect(@client.endpoints).to eq(endpoints)
          end
        end

        context 'when endpoints are not set' do
          before do
            @client = described_class.new(opts)
            @res = @client.call(endpoints[0]['id'])
          end

          it_behaves_like :list_endpoints

          it 'calls http requests 2 times' do
            expect(a_request(:get, url)).to have_been_made.times(2)
          end
        end

        context 'when endpoints are set' do
          before do
            @client = described_class.new(opts_with_endpoints)
            @res = @client.call(endpoints[0]['id'])
          end

          it_behaves_like :list_endpoints

          it 'calls http requests 1 time' do
            expect(a_request(:get, url)).to have_been_made.times(1)
          end
        end
      end

      context 'when authenticate' do
        authenticate_endpoints = [
          {
            'id' => 'authenticate',
            'route' => '/authentication',
            'version' => 1,
            'verb' => 'POST'
          }
        ]
        opts_with_authenticate = opts.merge(
          endpoints: authenticate_endpoints
        )

        let(:expected_res) { { 'accessToken' => 'token' } }

        before do
          url = opts[:base_url] + "/v#{api_version}" \
            + authenticate_endpoints[0]['route']
          stub = stub_request(:post, url)
          stub.to_return(body: expected_res.to_json)
          @client = described_class.new(opts_with_authenticate)
          @res = @client.call(authenticate_endpoints[0]['id'])
        end

        after { WebMock.reset! }

        it 'returns JSON' do
          expect(@res).to eq(expected_res)
        end

        it 'has accsssToken' do
          expect(@client.access_token).to eq('token')
        end
      end
    end
  end

  describe '#endpoints' do
    context 'when endpoints is set by opts' do
      client = described_class.new(opts_with_endpoints)

      it 'returns set endpoints' do
        expect(client.endpoints).to equal(endpoints)
      end
    end

    context 'when endpoints is not set by opts' do
      client = described_class.new(opts)

      it 'returns nil' do
        expect(client.endpoints).to be_nil
      end
    end
  end
end
