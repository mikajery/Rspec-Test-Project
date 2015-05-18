require 'rails_helper'

describe Google::Misc do
  let(:result) { double }

  it '#get_parameters_from_args' do
    expect(Google::Misc.get_parameters_from_args([{ a: 1, b: nil }, { b: nil, c: '2' }])).to eq({ a: 1 })
  end

  it '#get_exception' do
    allow(result).to receive_message_chain(:headers, :[])
    allow(result).to receive(:error_message) { 'error message' }

    [301, 302, 303, 307].each do |status|
      allow(result).to receive(:status) { status }
      expect(Google::Misc.get_exception(result)).to be_a Google::APIClient::RedirectError
    end

    (400...500).each do |status|
      allow(result).to receive(:status) { status }
      expect(Google::Misc.get_exception(result)).to be_a Google::APIClient::ClientError
    end

    (500...600).each do |status|
      allow(result).to receive(:status) { status }
      expect(Google::Misc.get_exception(result)).to be_a Google::APIClient::ServerError
    end

    allow(result).to receive(:status) { 200 }
    expect(Google::Misc.get_exception(result)).to be_a Google::APIClient::TransmissionError
  end
end
