require 'rails_helper'

describe Api::V1::SessionsController, :type => :request do
  context 'when the username and password is invalid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should not login the user' do
      post '/api/v1/sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status(:unauthorized)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when the password is invalid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should increment the login attempt counter' do
      expect(user.login_attempt_count).to eq(0)

      post '/api/v1/sessions', :email => user.email, :password => "#{user.password} invalid"

      expect(response).to have_http_status(:unauthorized)
      expect(response.cookies['auth_key']).to eq(nil)

      user.reload
      expect(user.login_attempt_count).to eq(1)
    end
  end

  context 'when the there are too many invalid password attemps the account should be locked' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should increment the login attempt counter' do
      expect(user.login_attempt_count).to eq(0)

      (1..$config.max_login_attempts).each do
        post '/api/v1/sessions', :email => user.email, :password => "#{user.password} invalid"

        expect(response).to have_http_status(:unauthorized)
        expect(response.cookies['auth_key']).to eq(nil)
      end

      user.reload
      expect(user.login_attempt_count).to eq($config.max_login_attempts)

      post '/api/v1/sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status($config.http_errors[:account_locked][:status_code])
      expect(response.cookies['auth_key']).to eq(nil)

      user.reload
      expect(user.login_attempt_count).to eq($config.max_login_attempts)
    end
  end

  context 'when the account is locked' do
    let(:user) { FactoryGirl.create(:locked_user) }

    it 'should not login the user' do
      post '/api/v1/sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status($config.http_errors[:account_locked][:status_code])
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when the username and password is valid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should login the user' do
      post '/api/v1/sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')
      expect(response.cookies['auth_key']).to_not eq(nil)
    end
  end

  context 'when the user is signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }

    it 'should logout the user' do
      delete '/api/v1/signout'

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when there user is not signed in' do
    it 'logout should still succeed' do
      delete '/api/v1/signout'

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end
end
