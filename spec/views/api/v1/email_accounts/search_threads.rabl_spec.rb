require 'rails_helper'

describe 'api/v1/email_accounts/search_threads', :type => :view do
  let(:next_page_token) { '0123456789' }
  let(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
  before { create_email_thread_emails(email_threads) }

  it 'returns the threads that match the search query' do
    assign(:next_page_token, next_page_token)
    assign(:email_threads, email_threads)

    render

    result = JSON.parse(rendered)
    next_page_token_rendered = result['next_page_token']
    email_threads_rendered = result['email_threads']

    expect(next_page_token_rendered).to eq(next_page_token)
    
    email_threads.zip(email_threads_rendered).each do |email_thread, email_thread_rendered|
      validate_email_thread(email_thread, email_thread_rendered)
    end
  end
end
