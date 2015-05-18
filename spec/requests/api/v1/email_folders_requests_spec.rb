require 'rails_helper'

describe Api::V1::EmailFoldersController, :type => :request do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let!(:gmail_account_other) { FactoryGirl.create(:gmail_account) }
  let!(:email_folders) { FactoryGirl.create_list(:gmail_label, SpecMisc::MEDIUM_LIST_SIZE, :gmail_account => gmail_account) }
  let!(:email_folders_other) { FactoryGirl.create_list(:gmail_label, SpecMisc::MEDIUM_LIST_SIZE, :gmail_account => gmail_account_other) }

  context 'when the user is NOT signed in' do
    it 'should NOT show the email folders' do
      get '/api/v1/email_folders'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    it 'should show the email folders' do
      get '/api/v1/email_folders'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_models_expected(email_folders, email_folders_rendered, 'label_id')
    end

    it 'should NOT show the other email folders' do
      get '/api/v1/email_folders'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_models_unexpected(email_folders_other, email_folders_rendered, 'label_id')
    end
  end

  context 'when the other user is signed in' do
    before { post '/api/v1/sessions', :email => gmail_account_other.user.email, :password => gmail_account_other.user.password }

    it 'should show the other email folders' do
      get '/api/v1/email_folders'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_models_expected(email_folders_other, email_folders_rendered, 'label_id')
    end

    it 'should NOT show the email folders' do
      get '/api/v1/email_folders'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_models_unexpected(email_folders, email_folders_rendered, 'label_id')
    end
  end
end
