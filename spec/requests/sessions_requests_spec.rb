require 'rails_helper'

describe SessionsController, :type => :request do
  describe ".new" do
    let!(:url) {
      gmail_o_auth2_url.gsub(/localhost:4000/, 'www.example.com')
    }

    it 'redirects to the gmail oauth2 url' do
      get signin_path
      expect(response).to redirect_to url
    end
  end #__End of describe ".new"__ 

  describe ".create" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:url) {
      gmail_o_auth2_url.gsub(/localhost:4000/, 'www.example.com')
    }

    it 'redirects to the gmail oauth2 url' do
      post sessions_path, :session => { :email => user.email, :password => user.password }

      expect(response).to redirect_to url
    end
  end #__End of describe ".create"__ 

  describe ".destroy" do
    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'sign out' do
        expect_any_instance_of(UserAuthKey).to receive(:destroy)
        delete signout_path
      end
    end #__End of context "when the user is signed in"__

    it 'redirects to the gmail oauth2 url' do
      delete signout_path

      expect(response).to redirect_to root_url
    end
  end #__End of describe ".destroy"__ 

  describe ".switch_account" do
    let!(:url) {
      gmail_o_auth2_url.gsub(/localhost:4000/, 'www.example.com')
    }

    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'sign out' do
        expect_any_instance_of(UserAuthKey).to receive(:destroy)
        delete switch_account_path
      end
    end #__End of context "when the user is signed in"__

    it 'redirects to the gmail oauth2 url' do
      delete switch_account_path

      expect(response).to redirect_to url
    end
  end #__End of describe ".switch_account"__
end
