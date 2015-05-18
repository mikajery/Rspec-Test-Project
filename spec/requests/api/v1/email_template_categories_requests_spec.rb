require 'rails_helper'

describe Api::V1::EmailTemplateCategoriesController, :type => :request do

  context 'creating email template categories' do
    let!(:user) { FactoryGirl.create(:user) }

    before { post '/api/v1/sessions', :email => user.email, :password => user.password }

    it 'should create an email template category' do
      post '/api/v1/email_template_categories', :name => 'Email template name'

      expect(response).to have_http_status(:ok)
      expect(user.email_template_categories.count).to eq(1)
    end

    it 'renders the api/v1/email_template_categories/show rabl' do
      expect( post '/api/v1/email_template_categories', :name => 'Email template category name').to render_template('api/v1/email_template_categories/show')
    end

    context "when the ActiveRecord::RecordNotUnique raises" do
      before do
        allow(EmailTemplateCategory).to receive(:create!) {
          raise  ActiveRecord::RecordNotUnique.new(1,2)
        }

        post '/api/v1/email_template_categories', :name => 'Email template name'
      end

      it 'responds with the email template category in use status code' do
        expect(response.status).to eq($config.http_errors[:email_template_category_name_in_use][:status_code])
      end

      it 'returns the email template category name in use message' do
        expect(response.body).to eq($config.http_errors[:email_template_category_name_in_use][:description])
      end
    end
  end

  context 'retrieving email template categories' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_template_categories) { FactoryGirl.create_list(:email_template_category, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }

    before { post '/api/v1/sessions', :email => user.email, :password => user.password }

    it 'should return the existing email template category' do
      get '/api/v1/email_template_categories'
      email_template_categories_rendered = JSON.parse(response.body)

      expect(email_template_categories_rendered.length).to eq(email_template_categories.length)
      email_template_categories.zip(email_template_categories_rendered).each do |email_template_category, email_template_category_rendered|
        validate_email_template_category(email_template_category, email_template_category_rendered)
      end
    end
  end

  context 'updating email template categories' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template_category) { FactoryGirl.create(:email_template_category, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should updates the email template category' do
        patch "/api/v1/email_template_categories/#{email_template_category.uid}", :name => 'Email template category name 2'
        expect(response).to have_http_status(:ok)

        email_template_category.reload
        expect(email_template_category.name).to eq('Email template category name 2')
      end

      it 'renders the api/v1/email_template_categories/show rabl' do
        expect( patch "/api/v1/email_template_categories/#{email_template_category.uid}", :name => 'Email template category name 2' ).to render_template('api/v1/email_template_categories/show')
      end

      context "when the ActiveRecord::RecordNotUnique raises" do
        before do
          allow_any_instance_of(EmailTemplateCategory).to receive(:update_attributes!) {
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }

          patch "/api/v1/email_template_categories/#{email_template_category.uid}", :name => 'Email template category name'
        end

        it 'responds with the email template category name in use status code' do
          expect(response.status).to eq($config.http_errors[:email_template_category_name_in_use][:status_code])
        end

        it 'returns the email template category name in use message' do
          expect(response.body).to eq($config.http_errors[:email_template_category_name_in_use][:description])
        end
      end

    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT update the email template category' do
        nameBefore = email_template_category.name

        patch "/api/v1/email_template_categories/#{email_template_category.uid}", :name => 'Email template category name'
        expect(response).to have_http_status($config.http_errors[:email_template_category_not_found][:status_code])

        email_template_category.reload

        expect(email_template_category.name).to eq(nameBefore)
      end

    end

  end

  context 'deleting email template categories' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template_category) { FactoryGirl.create(:email_template_category, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should delete the email template category' do
        expect(user.email_template_categories.count).to eq(1)
        delete "/api/v1/email_template_categories/#{email_template_category.uid}"
        expect(user.email_template_categories.count).to eq(0)
      end
    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT delete the templateemail template category' do
        expect(user.email_template_categories.count).to eq(1)

        delete "/api/v1/email_template_categories/#{email_template_category.uid}"
        expect(response).to have_http_status($config.http_errors[:email_template_category_not_found][:status_code])

        expect(user.email_template_categories.count).to eq(1)
      end
    end
  end
end
