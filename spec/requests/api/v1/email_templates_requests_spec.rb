require 'rails_helper'

describe Api::V1::EmailTemplatesController, :type => :request do

  context 'creating templates' do
    let!(:user) { FactoryGirl.create(:user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should create a template' do
      post '/api/v1/email_templates', :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
      
      expect(response).to have_http_status(:ok)
      expect(user.email_templates.count).to eq(1)
    end

    it 'renders the api/v1/email_templates/show rabl' do            
      expect( post '/api/v1/email_templates', :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>' ).to render_template('api/v1/email_templates/show')
    end

    context "when the ActiveRecord::RecordNotUnique raises" do
      before do
        allow(EmailTemplate).to receive(:create!) { 
          raise  ActiveRecord::RecordNotUnique.new(1,2)
        }

        post '/api/v1/email_templates', :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
      end

      it 'responds with the email signature template in use status code' do
        expect(response.status).to eq($config.http_errors[:email_template_name_in_use][:status_code])
      end

      it 'returns the email template name in use message' do
        expect(response.body).to eq($config.http_errors[:email_template_name_in_use][:description])
      end
    end
  end

  context 'retrieving templates' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_templates) { FactoryGirl.create_list(:email_template, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing templates' do
      get '/api/v1/email_templates'
      email_templates_rendered = JSON.parse(response.body)
      
      expect(email_templates_rendered.length).to eq(email_templates.length)
      email_templates.zip(email_templates_rendered).each do |email_template, email_template_rendered|
        validate_email_template(email_template, email_template_rendered)
      end
    end
  end

  context 'updating templates' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template) { FactoryGirl.create(:email_template, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should updates the template' do
        patch "/api/v1/email_templates/#{email_template.uid}", :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        expect(response).to have_http_status(:ok)

        email_template.reload
        expect(email_template.name).to eq('Email template name')
        expect(email_template.text).to eq('lorem ipsum')
        expect(email_template.html).to eq('<div>lorem ipsum</div>')
      end

      it 'renders the api/v1/email_templates/show rabl' do            
        expect( patch "/api/v1/email_templates/#{email_template.uid}", :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>' ).to render_template('api/v1/email_templates/show')
      end

      context "when the ActiveRecord::RecordNotUnique raises" do
        before do
          allow_any_instance_of(EmailTemplate).to receive(:update_attributes!) { 
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }

          patch "/api/v1/email_templates/#{email_template.uid}", :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        end

        it 'responds with the email signature name in use status code' do
          expect(response.status).to eq($config.http_errors[:email_template_name_in_use][:status_code])
        end

        it 'returns the email signature name in use message' do
          expect(response.body).to eq($config.http_errors[:email_template_name_in_use][:description])
        end
      end

    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT update the template' do
        nameBefore = email_template.name
        textBefore = email_template.text
        htmlBefore = email_template.html

        patch "/api/v1/email_templates/#{email_template.uid}", :name => 'Email template name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        expect(response).to have_http_status($config.http_errors[:email_template_not_found][:status_code])

        email_template.reload

        expect(email_template.name).to eq(nameBefore)
        expect(email_template.text).to eq(textBefore)
        expect(email_template.html).to eq(htmlBefore)
      end

    end
  
  end

  context 'deleting templates' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template) { FactoryGirl.create(:email_template, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should delete the template' do
        expect(user.email_templates.count).to eq(1)
        delete "/api/v1/email_templates/#{email_template.uid}"
        expect(user.email_templates.count).to eq(0)
      end
    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT delete the template' do
        expect(user.email_templates.count).to eq(1)
        
        delete "/api/v1/email_templates/#{email_template.uid}"
        expect(response).to have_http_status($config.http_errors[:email_template_not_found][:status_code])
        
        expect(user.email_templates.count).to eq(1)
      end
    end
  end
end
