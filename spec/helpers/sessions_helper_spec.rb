require 'rails_helper'

describe SessionsHelper, :type => :helper do
  describe '#user_signin_attempt' do
    let!(:email) { "user@email.com" }
    let!(:password) { "password" }

    context "when the user with the email does not exist" do
      context "for no api" do
        it 'produces the invalid email/password combination flash message' do
          helper.should_receive("render").with("new")
          helper.user_signin_attempt(email, password)
          expect(flash[:danger]).to eq('Invalid email/password combination')
        end

        it 'renders the new page' do
          helper.should_receive("render").with("new")
          helper.user_signin_attempt(email, password)
        end
      end #__End of context "for no api"__

      context "for the api" do
        it 'renders the json error' do
          helper.should_receive("render").with(:json => 'Invalid email/password combination', :status => 401)
          helper.user_signin_attempt(email, password, true)
        end
      end #__End of context "for the api"__
    end #__End of context "when the user with the email does not exist"__

    context "when the user with the email does exist" do
      let!(:user) { FactoryGirl.create(:user, email: email) }

      it 'increments the counter' do
        expect(User).to receive(:increment_counter)
        helper.should_receive("render").with("new")
        helper.user_signin_attempt(email, password)
      end

      context "when the login attempt counts is greater than max login attempts" do
        before do
          user.login_attempt_count = $config.max_login_attempts + 1
          user.save!
        end

        context "for no api" do
          it 'produces the danger flash message' do
            helper.should_receive("redirect_to").with(reset_password_url)
            helper.user_signin_attempt(email, password)
            expect(flash[:danger]).to eq('Your account has been locked to protect your security. Please reset your password.')
          end

          it 'redirects to the reset password page' do
            helper.should_receive("redirect_to").with(reset_password_url)
            helper.user_signin_attempt(email, password)
          end
        end #__End of context "for no api"__

        context "for the api" do
          it 'renders the json error' do
            helper.should_receive("render").with(:status => $config.http_errors[:account_locked][:status_code], :json => $config.http_errors[:account_locked][:description])
            helper.user_signin_attempt(email, password, true)
          end
        end #__End of context "for the api"__
      end #__End of context "when the login attempt counts is greater than max login attempts"__

      context "when the login attempt counts is smaller than max login attempts" do
        context "when the password is passed" do
          context "for no api" do
            it 'redirects to back or the root page' do
              helper.should_receive("redirect_back_or").with(root_path)
              helper.user_signin_attempt(email, 'Foobar!1')
            end
          end #__End of context "for no api"__

          context "for the api" do
            it 'renders the users/show page' do
              helper.should_receive("render").with('api/v1/users/show')
              helper.user_signin_attempt(email, 'Foobar!1', true)
            end
          end #__End of context "for the api"__
        end #__End of context "when the password is passed"__
      end #__End of context "when the login attempt counts is smaller than max login attempts"__
    end #__End of context "when the user with the email does exist"__
  end #__End of describe "#user_signin_attempt"__

  describe "#sign_in" do
    let!(:user) { FactoryGirl.create(:user) }

    it 'returns the user' do
      expect( helper.sign_in(user) ).to eq(user)
    end
  end #__End of describe "#sign_in"__

  describe "#signed_in?" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the user is already signed in" do
      before do
        helper.sign_in(user)
      end

      it 'returns the true' do
        expect( helper.signed_in? ).to eq(true)
      end
    end #__End of context "when the user is already signed in"__

    context "when the user is not already signed in" do
      it 'returns the false' do
        expect( helper.signed_in? ).to eq(false)
      end
    end
  end #__End of describe "#signed_in?"__

  describe "#current_user=" do
    let!(:user) { FactoryGirl.create(:user) }

    it 'assigns the current_user instance variable to the user' do
      helper.current_user = user

      expect( helper.instance_variable_get(:@current_user) ).to eq(user)
    end
  end #__End of describe "#current_user="__

  describe "#current_user" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the auth_key cookies is nil" do
      it 'returns nil' do
        expect( helper.current_user ).to eq(nil)
      end
    end #__End of context "when the auth_key cookies is nil"__

    context "when the auth_key cookies is not nil" do
      before do
        helper.cookies[:auth_key] = "auth key"
      end

      context "when the current_user instance variable exists" do
        before do
          helper.current_user = user
        end

        it 'returns the current user' do
          expect( helper.current_user ).to eq(user)
        end
      end #__End of context "when the current_user instance variable exists"__

      context "when the current_user instance variable does not exist" do
        it 'encrypts the auth key' do
          expect(UserAuthKey).to receive(:secure_hash).with("auth key")
          helper.current_user
        end

        it 'finds the cached user auth key with the encrypted auth key' do
          allow(UserAuthKey).to receive(:secure_hash).and_return("user-auth-key")
          expect(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).with("user-auth-key")
          helper.current_user
        end

        context "when finds the cached user auth key with the encrypted auth key" do
          let!(:user_auth_key) { UserAuthKey.new }
          before do
            allow(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).and_return(user_auth_key)
          end

          it 'finds the cached user' do
            expect(User).to receive(:cached_find)
            helper.current_user
          end

          it 'returns the cached user' do
            allow(User).to receive(:cached_find).and_return(user)
            expect( helper.current_user ).to eq(user)
          end
        end #__End of context "when finds the cached user auth key with the encrypted auth key"__

        context "when does not find the cached user auth key with the encrypted auth key" do
          before do
            allow(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).and_return(nil)
          end

          it 'returns nil' do
            expect( helper.current_user ).to eq(nil)
          end
        end #__End of context "when does not find the cached user auth key with the encrypted auth key"__
      end #__End of context "when the current_user instance variable does not exist"__
    end #__End of context "when the auth_key cookies is not nil"__
  end #__End of describe "#current_user"__

  describe "#current_user?" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:another_user) { FactoryGirl.create(:user) }

    context "when the user is equal to the current user" do
      before do
        helper.sign_in(user)
      end

      it 'returns true' do
        expect( helper.current_user?(user) ).to eq(true)
      end
    end #__End of context "when the user is equal to the current user"__

    context "when the user is not equal to the current user" do
      before do
        helper.sign_in(another_user)
      end

      it 'returns false' do
        expect( helper.current_user?(user) ).to eq(false)
      end
    end #__End of context "when the user is not equal to the current user"__
  end #__End of describe "#current_user?"__

  describe "#signed_in_user" do

    context "for the api" do
      it 'renders json error' do
        helper.should_receive("render").with(:json => 'Not signed in.', :status => 401)
        helper.signed_in_user(true)
      end
    end #__End of context "for the api"__

    context "for no api" do
      it 'redirects to the sign in page' do
        helper.should_receive("redirect_to")
        helper.signed_in_user
      end
    end #__End of context "for no api"__
  end #__End of describe "#signed_in_user"__

  describe "#correct_email_account" do
    context "when the user is NOT sign in" do
      it 'raises the error' do
        expect{ helper.correct_email_account }.to raise_error
      end
    end #__End of context "when the user is NOT sign in"__

    context "when the user is sign in" do
      context "when the user does not have any gmail account" do
        let!(:user) { FactoryGirl.create(:user) }
        before do
          helper.sign_in(user)
        end

        it 'renders the email accoutn not found json error' do
          helper.should_receive("render").with(:status => $config.http_errors[:email_account_not_found][:status_code], :json => $config.http_errors[:email_account_not_found][:description])
          helper.correct_email_account
        end
      end #__End of context "when the user does not have any gmail account"__

      context "when the user has any gmail account" do
        let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
        before do
          helper.sign_in(gmail_account.user)
        end

        it 'assigns the email_account instance variable to the first gmail account' do
          helper.correct_email_account
          expect( helper.instance_variable_get(:@email_account) ).to eq(gmail_account)
        end
      end #__End of context "when the user has any gmail account"__
    end #__End of context "when the user is sign in"__
  end #__End of describe "#correct_email_account"__

  describe "#sign_out" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the auth_key cookie exists" do
      before do
        helper.sign_in(user)
      end

      context "when finds the user auth key by the auth_key cookie" do
        let!(:user_auth_key) { UserAuthKey.new }
        before do
          allow(UserAuthKey).to receive(:find_by).and_return(user_auth_key)
        end

        xit 'destroys the user auth key' do
          expect_any_instance_of(UserAuthKey).to receive(:destroy)
          helper.sign_out
        end
      end #__End of context "when finds the user auth key by the auth_key cookie"__
    end #__End of context "when the auth_key cookie exists"__

    it 'deletes the auth_key cookie' do
      helper.sign_out
      expect( helper.cookies[:auth_key] ).to eq(nil)
    end

    it 'sets the current user to nil' do
      helper.sign_out
      expect( helper.current_user ).to eq(nil)
    end
  end #__End of describe "#sign_out"__

  describe "#redirect_back_or" do
    context "when the return_to session exists" do
      before do
        helper.session[:return_to] = "return_to"
      end

      it 'redirects to the return_to url' do
        helper.should_receive("redirect_to").with("return_to")
        helper.redirect_back_or("default")
      end

      it 'deletes the return_to session' do
        helper.should_receive("redirect_to")
        helper.redirect_back_or("default")
        expect( helper.session[:return_to] ).to eq(nil)
      end
    end #__End of context "when the return_to session exists"__

    context "when the return_to session does not exists" do
      it 'redirects to the default url' do
        helper.should_receive("redirect_to").with("default")
        helper.redirect_back_or("default")
      end
    end #__End of context "when the return_to session does not exist"__
  end #__End of describe "#redirect_back_or"__

  describe "#store_location" do
    context "for the get request" do
      it 'sets the return_to session to the request url' do
        helper.store_location
        expect( helper.session[:return_to] ).to eq(helper.request.url)
      end
    end #__End of context "for the get request"__
  end #__End of describe "#store_location"__
end
