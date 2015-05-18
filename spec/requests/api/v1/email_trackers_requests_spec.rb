require 'rails_helper'

describe Api::V1::EmailTrackersController, :type => :request do

  context 'retrieving trackers' do
    let!(:user_with_gmail_accounts) { FactoryGirl.create(:user_with_gmail_accounts) }
    let!(:email_trackers) { FactoryGirl.create_list(:email_tracker, SpecMisc::MEDIUM_LIST_SIZE, :email_account => user_with_gmail_accounts.gmail_accounts.first) }
    
    before { post '/api/v1/sessions', :email => user_with_gmail_accounts.email, :password => user_with_gmail_accounts.password }
    
    it 'should return the existing trackers' do
      get '/api/v1/email_trackers'
      email_trackers_rendered = JSON.parse(response.body)
      
      expect(email_trackers_rendered.length).to eq(email_trackers.length)
      # TODO validate attributes.
      # email_trackers.zip(email_trackers_rendered).each do |email_tracker, email_tracker_rendered|
      #   validate_email_tracker(email_tracker, email_tracker_rendered)
      # end
    end

  end

end
