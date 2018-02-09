require 'spec_helper.rb'

require 'tempfile'
require 'webmock/rspec'

require 'mt/data_api/client/api_request'
require 'mt/data_api/client/endpoint'
require 'mt/data_api/client/endpoint_manager'

describe MT::DataAPI::Client::APIRequest do
  api_url = 'http://localhost/mt/mt-data-api.cgi/v3'
  MT::DataAPI::Client::Endpoint.api_url = api_url

  def list_endpoints_endpoint
    MT::DataAPI::Client::Endpoint.new(
      MT::DataAPI::Client::EndpointManager::LIST_ENDPOINTS_HASH
    )
  end

  describe '#initialize' do
    it "returns an instance of #{described_class}" do
      api_request = described_class.new(list_endpoints_endpoint)
      expect(api_request).to be_instance_of(described_class)
    end
  end

  describe '#send' do
    def endpoint_hash(verb)
      {
        id: "#{verb.downcase}_endpoint",
        route: "/#{verb.downcase}",
        version: 1,
        verb: verb.upcase
      }
    end

    shared_examples_for :ok_response do
      it 'returns 200 ok response' do
        api_request = described_class.new(endpoint)
        res = api_request.send(access_token, args)
        expect(res.code).to eq('200')
        expect(res.body).to eq('{}')
      end
    end

    after(:each) { WebMock.reset! }

    context 'when POST method' do
      context 'without parameters' do
        before do
          url = "#{api_url}/post"
          WebMock.stub_request(:post, url).to_return(body: '{}')
        end

        let(:endpoint) do
          hash = endpoint_hash('POST')
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { nil }
        let(:args) { {} }

        it_behaves_like :ok_response
      end

      context 'with parameters' do
        before do
          url = "#{api_url}/post"
          stub = WebMock.stub_request(:post, url)
          stub.with(body: 'id=3&name=test').to_return(body: '{}')
        end

        let(:endpoint) do
          hash = endpoint_hash('POST')
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { nil }
        let(:args) { { id: 3, name: 'test' } }

        it_behaves_like :ok_response
      end

      context 'with file' do
        before do
          url = "#{api_url}/assets/upload"
          stub_request(:post, url)
            .with(headers: { 'Content-Type' => 'multipart/form-data' })
            .to_return(body: '{}')
        end

        let(:endpoint) do
          hash = {
            id: 'upload_asset',
            route: '/assets/upload',
            version: 2,
            verb: 'POST',
          }
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { 'token' }
        let(:args) { { site_id: 1, file: Tempfile.create('foo') } }

        it_behaves_like :ok_response
      end
    end

    context 'when PUT method' do
      context 'without parameters' do
        before do
          url = "#{api_url}/put"
          WebMock.stub_request(:put, url).to_return(body: '{}')
        end

        let(:endpoint) do
          hash = endpoint_hash('PUT')
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { nil }
        let(:args) { {} }

        it_behaves_like :ok_response
      end

      context 'with parameters' do
        before do
          url = "#{api_url}/put"
          stub = WebMock.stub_request(:put, url)
          stub.with(body: 'name=sample&id=9').to_return(body: '{}')
        end

        let(:endpoint) do
          hash = endpoint_hash('PUT')
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { nil }
        let(:args) { { name: 'sample', id: 9 } }

        it_behaves_like :ok_response
      end

      context 'with file' do
        before do
          url = "#{api_url}/put_file"
          stub_request(:put, url)
            .with(headers: { 'Content-Type' => 'multipart/form-data' })
            .to_return(body: '{}')
        end

        let(:endpoint) do
          hash = {
            id: 'put_file',
            route: '/put_file',
            version: 1,
            verb: 'PUT',
          }
          MT::DataAPI::Client::Endpoint.new(hash)
        end
        let(:access_token) { 'token' }
        let(:args) { { put_file: Tempfile.create('foo') } }

        it_behaves_like :ok_response
      end
    end

    context 'with access_token' do
      access_token = 'test_token'

      before do
        headers = {
          'X-MT-Authorization' => "MTAuth accessToken=#{access_token}"
        }
        stub = WebMock.stub_request(:get, "#{api_url}/endpoints")
        stub.with(headers: headers).to_return(body: '{}')
      end

      let(:endpoint) { list_endpoints_endpoint }
      let(:access_token) { access_token }
      let(:args) { {} }

      it_behaves_like :ok_response
    end
  end
end
