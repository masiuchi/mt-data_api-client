require 'spec_helper.rb'

require 'json'

require 'webmock/rspec'

require 'mt/data_api/client/endpoint'
require 'mt/data_api/client/endpoint_manager'

describe MT::DataAPI::Client::EndpointManager do
  base_url = 'http://localhost/mt/mt-data-api.cgi'
  valid_args = {
    base_url: base_url,
    client_id: 'test'
  }

  describe '#initialize' do
    shared_examples_for :invalid_arguments do
      it 'raises ArgumentError' do
        expect { described_class.new(args) }.to raise_error(ArgumentError)
      end
    end

    context 'with valid arguments' do
      it "returns an instance of #{described_class}" do
        manager = described_class.new(valid_args)
        expect(manager).to be_instance_of(described_class)
      end

      it 'sets api_url to Endpoint class' do
        api_url = MT::DataAPI::Client::Endpoint.instance_variable_get(:@api_url)
        expect(api_url).to eq("#{base_url}/v3")
      end
    end

    context 'when api_version is set' do
      args = {
        base_url: base_url,
        client_id: 'test',
        api_version: 1
      }

      it 'has the api_version in api_url' do
        described_class.new(args)
        api_url = MT::DataAPI::Client::Endpoint.instance_variable_get(:@api_url)
        expect(api_url).to eq("#{base_url}/v1")
      end
    end

    context 'with not hash arguments' do
      let(:args) { 1 }
      it_behaves_like :invalid_arguments
    end

    context 'with empty hash' do
      let(:args) { {} }
      it_behaves_like :invalid_arguments
    end

    context 'with base_url only' do
      let(:args) { { base_url: base_url } }
      it_behaves_like :invalid_arguments
    end

    context 'with client_id only' do
      let(:args) { { client_id: 'test' } }
      it_behaves_like :invalid_arguments
    end
  end

  describe '#find_endpoint' do
    endpoints = [
      {
        'resources' => nil,
        'format' => nil,
        'component' => {
          'name' => 'Core',
          'id' => 'core'
        },
        'version' => 1,
        'verb' => 'GET',
        'id' => 'list_endpoints',
        'route' => '/endpoints'
      }
    ]

    shared_examples_for :find_endpoint do
      before(:each) do
        @manager = described_class.new(args)
      end

      context 'with valid id' do
        it 'returns endpoint instance' do
          endpoint = @manager.find_endpoint('list_endpoints')
          expect(endpoint).to be_an_instance_of(MT::DataAPI::Client::Endpoint)
        end
      end

      context 'with invalid id' do
        it 'returns nil' do
          endpoint = @manager.find_endpoint('invlid')
          expect(endpoint).to be_nil
        end
      end
    end

    context 'when endpoints are retrieved from server' do
      let(:args) do
        {
          base_url: 'http://localhost/mt/mt-data-api.cgi',
          client_id: 'test'
        }
      end

      before do
        response = { totalResults: 1, items: endpoints }
        WebMock.stub_request(:get, "#{args[:base_url]}/v3/endpoints")\
               .to_return(body: response.to_json)
      end

      after { WebMock.reset! }

      it_behaves_like :find_endpoint
    end

    context 'when endpoints are set by argument' do
      let(:args) do
        {
          base_url: base_url,
          client_id: 'test',
          endpoints: endpoints
        }
      end

      it_behaves_like :find_endpoint
    end
  end
end
