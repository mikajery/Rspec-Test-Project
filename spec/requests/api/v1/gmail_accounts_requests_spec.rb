require 'rails_helper'

describe Api::V1::GmailAccountsController, :type => :request do
  describe ".get_token" do
    context 'when the user is NOT signed in' do 
      before do
        get '/api/v1/gmail_accounts/get_token'
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
        get '/api/v1/gmail_accounts/get_token'
        expect(response.status).to eq(200)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".get_token"__
end
