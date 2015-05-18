require 'rails_helper'

describe Api::V1::DelayedEmailsController, :type => :request do
  describe ".index" do
    context 'when the user is NOT signed in' do 
      before do
        get '/api/v1/delayed_emails'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }

      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        get '/api/v1/delayed_emails'
        expect(response.status).to eq(200)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe ".destroy" do
    context 'when the user is NOT signed in' do 
      let!(:email_account) { FactoryGirl.create(:gmail_account) }
      let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }
      let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job.id) }

      before do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:email_account) { FactoryGirl.create(:gmail_account) }
      let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }
      let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job.id) }

      before { post '/api/v1/sessions', :email => email_account.user.email, :password => email_account.user.password }

      it 'responds with a 200 status code' do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".destroy"__
end
