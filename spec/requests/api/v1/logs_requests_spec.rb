require 'rails_helper'

describe Api::V1::LogsController, :type => :request do
  it 'should log the message' do
    post '/api/v1/log'
    
    expect(response).to have_http_status(:ok)
  end
end
