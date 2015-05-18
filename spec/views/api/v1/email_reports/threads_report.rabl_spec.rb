require 'rails_helper'

describe 'api/v1/email_reports/threads_report', :type => :view do
  let(:average_thread_length) { 5 }
  let(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
  before { create_email_thread_emails(email_threads) }

  it 'returns the threads report stats' do
    assign(:average_thread_length, average_thread_length)
    assign(:top_email_threads, email_threads)

    render

    result = JSON.parse(rendered)

    average_thread_length_rendered = result['average_thread_length']
    email_threads_rendered = result['top_email_threads']

    expect(average_thread_length_rendered).to eq(average_thread_length)

    email_threads.zip(email_threads_rendered).each do |email_thread, email_thread_rendered|
      expect(email_thread.uid).to eq(email_thread_rendered["uid"])
      expect(email_thread.emails_count).to eq(email_thread_rendered["emails_count"])
    end
  end
end