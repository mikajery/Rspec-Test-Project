require 'rails_helper'

describe Google::GmailClient do
  let(:api_client) { Google::APIClient.new(application_name: 'Example Ruby application',
                                           application_version: '1.0.0')
                   }
  let(:gmail_client) { Google::GmailClient.new(api_client) }
  let(:gmail_api) { double }
  let(:result) { double(data: 'data') }
  let(:userId) { 1 }
  let(:messageId) { 1 }
  let(:id) { 1 }

  before do
    allow(api_client).to receive(:execute!) { result }
    allow(gmail_client).to receive(:gmail_api) { gmail_api }
  end

  it '.drafts_delete' do
    allow(gmail_api).to receive_message_chain(:users, :drafts, :delete)

    expect(gmail_client.drafts_delete(userId, id)).to eq(result.data)
  end

  it '.drafts_send' do
    allow(gmail_api).to receive_message_chain(:users, :drafts, :to_h, :[])

    expect(gmail_client.drafts_send(userId, id)).to eq(result.data)
  end

  it '.drafts_update' do
    allow(gmail_api).to receive_message_chain(:users, :drafts, :update)

    expect(gmail_client.drafts_update(userId, id)).to eq(result.data)
  end

  it '.drafts_create' do
    allow(gmail_api).to receive_message_chain(:users, :drafts, :create)

    expect(gmail_client.drafts_create(userId)).to eq(result.data)
  end

  it '.drafts_list' do
    allow(gmail_api).to receive_message_chain(:users, :drafts, :list)

    expect(gmail_client.drafts_list(userId)).to eq(result.data)
  end

  it '.history_list' do
    allow(gmail_api).to receive_message_chain(:users, :history, :list)

    expect(gmail_client.history_list(userId)).to eq(result.data)
  end

  it '.attachments_get' do
    resp = double(body: { result: 'result' }.to_json)
    allow(gmail_client).to receive(:attachments_get_call)
    allow(result).to receive_message_chain(:response, :body) { resp.body }

    expect(gmail_client.attachments_get(userId, messageId, id)).to eq JSON.parse(resp.body)
  end

  it '.attachments_get_call' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :attachments, :get) { 'api_method' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.attachments_get_call(userId, messageId, id)).to eq({ api_method: 'api_method',
                                                                             parameters: { result: result } })
  end

  it '.messages_send' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :to_h, :[])

    expect(gmail_client.messages_send(userId)).to eq(result.data)
  end

  it '.messages_trash' do
    allow(gmail_client).to receive(:messages_trash_call)

    expect(gmail_client.messages_trash(userId, id)).to eq(result.data)
  end

  it '.messages_trash_call' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :trash) { 'api_messages_trash' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.messages_trash_call(userId, id)).to eq({ api_method: 'api_messages_trash',
                                                                 parameters: { result: result } })
  end

  it '.messages_modify' do
    allow(gmail_client).to receive(:messages_modify_call)

    expect(gmail_client.messages_modify(userId, id)).to eq(result.data)
  end

  it '.messages_modify_call' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :modify) { 'api_messages_modify' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.messages_modify_call(userId, id, addLabelIds: nil, removeLabelIds: nil)).to eq(api_method: 'api_messages_modify',
                                                                                                       parameters: { result: result },
                                                                                                       body_object: {})
    expect(gmail_client.messages_modify_call(userId, id, addLabelIds: true, removeLabelIds: nil)).to eq(api_method: 'api_messages_modify',
                                                                                                        parameters: { result: result },
                                                                                                        body_object: { addLabelIds: true })
    expect(gmail_client.messages_modify_call(userId, id, addLabelIds: nil, removeLabelIds: true)).to eq(api_method: 'api_messages_modify',
                                                                                                        parameters: { result: result },
                                                                                                        body_object: { removeLabelIds: true })
  end

  it '.messages_trash_call' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :get) { 'api_messages_get' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.messages_get_call(userId, id)).to eq({ api_method: 'api_messages_get',
                                                               parameters: { result: result } })
  end

  it '.messages_get' do
    allow(gmail_client).to receive(:messages_get_call)

    expect(gmail_client.messages_get(userId, id)).to eq(result.data)
  end

  it '.messages_list' do
    allow(gmail_api).to receive_message_chain(:users, :messages, :list) { 'api_messages_list' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.messages_list(userId)).to eq(result.data)
  end

  it '.threads_get_call' do
    allow(gmail_api).to receive_message_chain(:users, :threads, :get) { 'api_threads_get' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.threads_get_call(userId, id)).to eq({ api_method: 'api_threads_get',
                                                              parameters: { result: result } })
  end

  it '.threads_get' do
    allow(gmail_client).to receive(:threads_get_call)

    expect(gmail_client.threads_get(userId, id)).to eq(result.data)
  end

  it '.threads_list' do
    allow(gmail_api).to receive_message_chain(:users, :threads, :list) { 'api_threads_list' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.threads_list(userId)).to eq(result.data)
  end

  it '.labels_get' do
    allow(gmail_api).to receive_message_chain(:users, :labels, :get) { 'api_labels_get' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.labels_get(userId, id)).to eq(result.data)
  end

  it '.labels_list' do
    allow(gmail_api).to receive_message_chain(:users, :labels, :list) { 'api_labels_list' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.labels_list(userId)).to eq(result.data)
  end

  it '.labels_create' do
    allow(gmail_api).to receive_message_chain(:users, :labels, :create) { 'api_labels_create' }
    allow(Google::Misc).to receive(:get_parameters_from_args).and_return({ result: result })

    expect(gmail_client.labels_create(userId, 'name')).to eq(result.data)
  end

  it '#handle_client_error' do
    ex = StandardError.new
    allow(ex).to receive_message_chain(:result, :data, :error)

    expect{ Google::GmailClient.handle_client_error(ex, 0) }.to raise_error
  end
end
