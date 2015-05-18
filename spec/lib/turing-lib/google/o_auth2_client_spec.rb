require 'rails_helper'

describe Google::OAuth2Client do
  let(:api_client) { Google::APIClient.new(application_name: 'Example Ruby application',
                                           application_version: '1.0.0')
                   }
  let(:o_auth2_client) { Google::OAuth2Client.new(api_client) }

  it '#tokeninfo' do
    result = double(data: 'data')
    o_auth2_api = double(tokeninfo: 'info')
    allow(api_client).to receive(:execute!) { result }
    allow(o_auth2_client).to receive(:o_auth2_api) { o_auth2_api }


    expect(o_auth2_client.tokeninfo(token: '12345')).to eq('data')
  end

  it '#userinfo_get' do
    result = double(data: 'data')
    info = double(get: 'result')
    o_auth2_api = double(userinfo: info)
    allow(api_client).to receive(:execute!) { result }
    allow(o_auth2_client).to receive(:o_auth2_api) { o_auth2_api }


    expect(o_auth2_client.userinfo_get).to eq('data')
  end

  it '.base_client' do
    client = Google::OAuth2Client.base_client('id', 'secret')

    expect(client).to be_a Signet::OAuth2::Client
    expect(client.client_id).to eq 'id'
    expect(client.client_secret).to eq 'secret'
  end
end
