require 'mt/data_api/client'
require 'mt/data_api/client/endpoint_manager'

describe MT::DataAPI::Client do
  opts = {
    base_url: 'http://localhost/mt/mt-data-api.cgi',
    client_id: 'test'
  }

  endpoints = [MT::DataAPI::Client::EndpointManager::LIST_ENDPOINTS_HASH]
  opts_endpoints = opts.merge(endpoints: endpoints)

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
      client = described_class.new(opts_endpoints)

      it 'raises error' do
        id = 'invalid'
        expect { client.call(id) }.to raise_error("no endpoint: #{id}")
      end
    end
  end

  describe '#endpoints' do
    context 'when endpoints is set by opts' do
      client = described_class.new(opts_endpoints)

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
