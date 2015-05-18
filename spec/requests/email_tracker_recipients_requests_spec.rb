require 'rails_helper'

describe EmailTrackerRecipientsController, :type => :request do
  describe ".confirmation" do
    let!(:email_tracker_recipient) { FactoryGirl.create(:email_tracker_recipient) }

    it "sets the Cache-Control of the headers with 'no-cache, no-store, must-revalidate'" do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect( response.headers["Cache-Control"] ).to eq( 'no-cache, no-store, must-revalidate' )
    end

    it "sets the Pragma of the headers with 'no-cache'" do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect( response.headers["Pragma"] ).to eq( 'no-cache' )
    end

    it "sets the Expires of the headers with '0'" do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect( response.headers["Expires"] ).to eq( '0' )
    end

    it 'creates new EmailTrackerView' do
      expect(EmailTrackerView.count).to eq(0)
      get "/confirmation/#{email_tracker_recipient.uid}"
      expect(EmailTrackerView.count).to eq(1)
    end

    it 'saves the email_tracker_recipient field to the email_tracker_recipient' do
      get "/confirmation/#{email_tracker_recipient.uid}"
      expect(EmailTrackerView.last.email_tracker_recipient).to eq(email_tracker_recipient)
    end

    it 'saves the ip_address field to the remote ip' do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect(EmailTrackerView.last.ip_address).to eq("127.0.0.1")
    end

    it 'saves the user_agent field to the user agent' do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect(EmailTrackerView.last.user_agent).to eq(nil)
    end

    it 'responses with 302 status code' do
      get "/confirmation/#{email_tracker_recipient.uid}"

      expect(response.status).to eq(302)
    end

    it 'is redirected to the confirmation image' do
      redirect_url = "#{root_url}assets/confirmation.gif"
      get "/confirmation/#{email_tracker_recipient.uid}"
      expect(response).to redirect_to redirect_url 
    end
  end #__End of describe ".confirmation"__ 
end
