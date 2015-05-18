require 'rails_helper'

describe StaticPagesController, :type => :request do
  describe ".landing" do
    it 'works' do
      get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2")
    end

    context 'when the user is NOT signed in' do
      it 'renders the landing page' do
        expect( get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template('static_pages/landing')
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'redirects to the mail url' do
        get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2")

        expect(response).to redirect_to mail_url
      end
    end #__End of context "when the user is signed in"__

  end #__End of describe ".landing"__

  describe ".mail" do
    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'renders the mail page' do
      	expect( get '/mail', nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template('static_pages/mail')
        # expect( get '/mail' ).to render_template('static_pages/mail')
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".mail"__

end
