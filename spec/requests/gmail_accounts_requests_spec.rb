require 'rails_helper'
require 'stringio'

describe GmailAccountsController, :type => :request do
  describe ".o_auth2_callback" do
    context "when the error params exists or code params is nil" do
    	let!(:params) {
    		{
    			:error => 'access_denied'
    		}
    	}
      context "when the error is access_denied" do
        it 'produces the access not granted error message' do
          get "/gmail_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t('gmail.access_not_granted'))
        end
      end

      it 'produces the default error message' do
        get "/gmail_oauth2_callback"        
        expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
      end

      it 'responses with 302 status code' do
        get "/gmail_oauth2_callback"
        expect(response.status).to eq(302)
      end

      it 'redirects to the root' do        
        get "/gmail_oauth2_callback"
        expect(response).to redirect_to root_url 
      end
    end #__End of describe "when the error params exists or code params is nil"__ 

    context "when the code params exists" do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:params) {
      	{
      		:code => "example code"
      	}
      }
      let!(:userinfo_data) {
        {
          'id' => 'user-id',
          'picture' => 'user-picture',
          'email' => 'user@email.com',
          'name' => 'user-name',
          'given_name' => 'user-given-name',
          'family_name' => 'user-family-name'
        }
      }

      before do
        allow_any_instance_of(Signet::OAuth2::Client).to receive(:fetch_access_token!)
      end

      context "when the user is already signed in" do
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'signed out' do
          expect_any_instance_of(UserAuthKey).to receive(:destroy)
          get "/gmail_oauth2_callback", params
        end
      end #__End of describe "when the user is already signed in"__ 

      it 'gets the api client with the code params' do
        expect_any_instance_of(GmailAccountsController).to receive(:get_api_client).with(params[:code])
        get "/gmail_oauth2_callback", params
      end

      context "when it gets the api client" do
        it 'creates the google OAuth2Client' do
          expect(Google::OAuth2Client).to receive(:base_client)
          get "/gmail_oauth2_callback", params
        end

        it 'fetches the access token by the google OAuth2Client' do
          expect_any_instance_of(Signet::OAuth2::Client).to receive(:fetch_access_token!)
          get "/gmail_oauth2_callback", params
        end

        it 'creates the GoogleOAuth2Token' do
          expect(GoogleOAuth2Token).to receive(:new)
          get "/gmail_oauth2_callback", params
        end

        it 'updates the GoogleOAuth2Token by the google OAuth2Client' do
          expect_any_instance_of(GoogleOAuth2Token).to receive(:update)
          get "/gmail_oauth2_callback", params
        end
      end #__End of describe "when it gets the api client"__ 

      context "after gets the api client successfully" do
        let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
        let!(:api_client) { Google::APIClient.new(:application_name => $config.service_name) }
        let!(:google_o_auth2_token) { GoogleOAuth2Token.new() }
        let!(:o_auth2_base_client) { Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret) }

        before do
          allow_any_instance_of(GmailAccountsController).to receive(:get_api_client).and_return(
            [google_o_auth2_token, api_client, o_auth2_base_client])
          allow(GmailAccount).to receive(:get_userinfo).and_return(userinfo_data)
        end

        it 'gets the user info data from the gmail account' do
          expect(GmailAccount).to receive(:get_userinfo).with(api_client).and_return(userinfo_data)
          get "/gmail_oauth2_callback", params
        end

        it 'finds the gmail account by the user id' do
          expect(GmailAccount).to receive(:find_by_google_id).with(userinfo_data['id']).and_return(false)
          get "/gmail_oauth2_callback", params
        end

        context "after finds the gmail account successfully" do

          before do
            $stdout = StringIO.new
            allow_any_instance_of(GmailAccountsController).to receive(:get_api_client).and_return(
                [google_o_auth2_token, api_client, o_auth2_base_client])
            allow(GmailAccount).to receive(:get_userinfo).and_return(userinfo_data)
            allow(GmailAccount).to receive(:find_by_google_id).and_return(gmail_account)
          end

          after(:all) do
            $stdout = STDOUT
          end

          it 'logs the gmail account' do
            out_string = "FOUND gmail_account=#{gmail_account.email}"
            get "/gmail_oauth2_callback", params
            expect($stdout.string).to match(/#{out_string}/)
          end

          context "when the user profile picture is not user data profile picture" do
            before do
              allow_any_instance_of(GmailAccount).to receive(:user).and_return(user)
            end

            it 'updates the profile picture to the user data profile picture' do
              get "/gmail_oauth2_callback", params
              user.reload
              expect(user.profile_picture).to eq( userinfo_data['picture'] )
            end
          end #__End of context "when the user profile picture is not user data profile picture"__ 

          it 'refreshes the google oauth2 token of the gmail account' do
            expect_any_instance_of(GoogleOAuth2Token).to receive(:refresh)
            get "/gmail_oauth2_callback", params
          end

          context "when the Signet::AuthorizationError raises" do
            before do
              allow_any_instance_of(GoogleOAuth2Token).to receive(:refresh) {
                raise Signet::AuthorizationError.new("message", {})
              }
            end

            it 'logs the message' do
              out_string = "BAD!!! refresh token - redirecting to gmail login!!!"
              get "/gmail_oauth2_callback", params
              expect($stdout.string).to match(/#{out_string}/)
            end

            it 'redirects to the gmail oauth2 url' do
              get "/gmail_oauth2_callback", params
              
              url = gmail_o_auth2_url(true)
              url.gsub!(/localhost:4000/, 'www.example.com')
              expect(response).to redirect_to url
            end
          end #__End of context "when the Signet::AuthorizationError raises"__ 

          it 'updates the google oauth2 token of the gmail account' do
            expect_any_instance_of(GoogleOAuth2Token).to receive(:update).at_most(:twice)

            get "/gmail_oauth2_callback", params
          end
        end #__End of context "after finds the gmail account successfully"__ 

        context "when fails to find the gmail account" do
          before do
            $stdout = StringIO.new
            allow_any_instance_of(GmailAccountsController).to receive(:get_api_client).and_return(
                [google_o_auth2_token, api_client, o_auth2_base_client])
            allow(GmailAccount).to receive(:get_userinfo).and_return(userinfo_data)
            allow(GmailAccount).to receive(:find_by_google_id).and_return(false)
          end

          after(:all) do
            $stdout = STDOUT
          end

          it 'logs the NOT FOUND gmail_account message' do
            out_string = "NOT FOUND gmail_account!!!"
            get "/gmail_oauth2_callback", params
            expect($stdout.string).to match(/#{out_string}/)
          end

          it 'logs the NO refresh token message' do
            out_string = "NO refresh token - redirecting to gmail login!!!"
            get "/gmail_oauth2_callback", params
            expect($stdout.string).to match(/#{out_string}/)
          end

          it 'redirects to the gmail oauth2 url' do
            get "/gmail_oauth2_callback", params
            
            url = gmail_o_auth2_url(true)
            url.gsub!(/localhost:4000/, 'www.example.com')
            expect(response).to redirect_to url
          end

          context "when the google oauth2 refresh token is not blank" do
            before do
              allow_any_instance_of(GoogleOAuth2Token).to receive(:refresh_token).and_return(true)
              allow_any_instance_of(GmailAccount).to receive(:refresh_user_info)
              allow_any_instance_of(GoogleOAuth2Token).to receive(:save!)
              allow_any_instance_of(GmailAccount).to receive(:save!)
            end

            it 'creates new user with the user data' do              
              get "/gmail_oauth2_callback", params
              
              user = User.last

              expect(user.email).to eq(userinfo_data['email'].downcase)
              expect(user.profile_picture).to eq(userinfo_data['picture'])
              expect(user.name).to eq(userinfo_data['name'])
              expect(user.given_name).to eq(userinfo_data['given_name'])
              expect(user.family_name).to eq(userinfo_data['family_name'])
            end

            it 'creates new gmail account' do
              expect_any_instance_of(GmailAccount).to receive(:save!)
              get "/gmail_oauth2_callback", params
            end

            it 'refreshes the user info' do
              expect_any_instance_of(GmailAccount).to receive(:refresh_user_info)
              get "/gmail_oauth2_callback", params
            end

            it 'sends the welcome email to the users' do
              expect(UserMailer).to receive(:delay)
              get "/gmail_oauth2_callback", params
            end

            it 'synchronizes the email' do
              expect_any_instance_of(GmailAccount).to receive(:delay)
              get "/gmail_oauth2_callback", params
            end

            it 'redirects to the mail url' do        
              get "/gmail_oauth2_callback", params
              expect(response).to redirect_to (mail_url + '#welcome_tour') 
            end 
          end #__End of context "when the google oauth2 refresh token is not blank"__ 
        end #__End of context "when fails to find the gmail account"__ 

        it 'sign in' do
          allow(GmailAccount).to receive(:get_userinfo).and_return(userinfo_data)
          allow(GmailAccount).to receive(:find_by_google_id).and_return(gmail_account)
          allow_any_instance_of(GoogleOAuth2Token).to receive(:update)
          
          # expect(UserAuthKey).to receive(:new)
          get "/gmail_oauth2_callback", params

          expect( UserAuthKey.last.user ).to eq( gmail_account.user )
        end
      end #__End of context "after gets the api client successfully"__ 

      context "when fails to get the api client" do
        it 'produces the default error message' do
          get "/gmail_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
        end
      end #__End of context "when fails to get the api client"__ 

      it 'redirects to the mail url' do        
        get "/gmail_oauth2_callback", params
        expect(response).to redirect_to mail_url 
      end
    end #__End of describe "when the code params exists"__ 
  end #__End of describe ".o_auth2_callback"__ 

  describe ".o_auth2_remove" do
    context 'when the user is NOT signed in' do 
      it 'raises the error' do
        expect { delete "/gmail_o_auth2_remove" }.to raise_error
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'produces the success message' do
        delete "/gmail_o_auth2_remove"
        expect(flash[:success]).to eq(I18n.t('gmail.unlinked'))
      end

      it 'redirects to the root' do        
        delete "/gmail_o_auth2_remove"
        expect(response).to redirect_to root_url 
      end

      context "when the current user has their gmail account" do
        it 'deletes the oauth2 token' do
          expect_any_instance_of(GmailAccount).to receive(:delete_o_auth2_token)
          delete "/gmail_o_auth2_remove"
        end

        it 'saves the last_history_id_synced field to nil' do
          delete "/gmail_o_auth2_remove"
          gmail_account.reload
          expect(gmail_account.last_history_id_synced).to eq(nil)
        end
      end #__End of context "when the current user has their gmail account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".o_auth2_remove"__
end
