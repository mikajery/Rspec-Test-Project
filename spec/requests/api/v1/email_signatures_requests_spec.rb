require 'rails_helper'

describe Api::V1::EmailSignaturesController, :type => :request do

  context 'creating signatures' do
    let!(:user) { FactoryGirl.create(:user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should create a signature' do
      post '/api/v1/email_signatures', :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
      
      expect(response).to have_http_status(:ok)
      expect(user.email_signatures.count).to eq(1)
    end

    it 'renders the api/v1/email_signatures/show rabl' do            
      expect( post '/api/v1/email_signatures', :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>' ).to render_template('api/v1/email_signatures/show')
    end

    context "when the ActiveRecord::RecordNotUnique raises" do
      before do
        allow(EmailSignature).to receive(:create!) { 
          raise  ActiveRecord::RecordNotUnique.new(1,2)
        }

        post '/api/v1/email_signatures', :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'        
      end

      it 'responds with the email signature name in use status code' do
        expect(response.status).to eq($config.http_errors[:email_signature_name_in_use][:status_code])
      end

      it 'returns the email signature name in use message' do
        expect(response.body).to eq($config.http_errors[:email_signature_name_in_use][:description])
      end
    end
  end

  context 'retrieving signatures' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_signatures) { FactoryGirl.create_list(:email_signature, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }

    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing signatures' do
      get '/api/v1/email_signatures'
      email_signatures_rendered = JSON.parse(response.body)
      
      expect(email_signatures_rendered.length).to eq(email_signatures.length)
      email_signatures.zip(email_signatures_rendered).each do |email_signature, email_signature_rendered|
        validate_email_signature(email_signature, email_signature_rendered)
      end
    end
  end

  context 'showing signatures' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_signature) { FactoryGirl.create(:email_signature, :user => user) }

    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'renders the api/v1/email_signatures/show rabl' do            
      expect( get "/api/v1/email_signatures/#{email_signature.uid}", :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>' ).to render_template('api/v1/email_signatures/show')
    end
  end

  context 'updating signatures' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_signature) { FactoryGirl.create(:email_signature, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should updates the signature' do
        patch "/api/v1/email_signatures/#{email_signature.uid}", :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        expect(response).to have_http_status(:ok)

        email_signature.reload
        expect(email_signature.name).to eq('Email signature name')
        expect(email_signature.text).to eq('lorem ipsum')
        expect(email_signature.html).to eq('<div>lorem ipsum</div>')
      end

      it 'renders the api/v1/email_signatures/show rabl' do            
        expect( patch "/api/v1/email_signatures/#{email_signature.uid}", :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>' ).to render_template('api/v1/email_signatures/show')
      end

      context "when the ActiveRecord::RecordNotUnique raises" do
        before do
          allow_any_instance_of(EmailSignature).to receive(:update_attributes!) { 
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }

          patch "/api/v1/email_signatures/#{email_signature.uid}", :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        end

        it 'responds with the email signature name in use status code' do
          expect(response.status).to eq($config.http_errors[:email_signature_name_in_use][:status_code])
        end

        it 'returns the email signature name in use message' do
          expect(response.body).to eq($config.http_errors[:email_signature_name_in_use][:description])
        end
      end
    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT update the signature' do
        nameBefore = email_signature.name
        textBefore = email_signature.text
        htmlBefore = email_signature.html

        patch "/api/v1/email_signatures/#{email_signature.uid}", :name => 'Email signature name', :text => 'lorem ipsum', :html => '<div>lorem ipsum</div>'
        expect(response).to have_http_status($config.http_errors[:email_signature_not_found][:status_code])

        email_signature.reload

        expect(email_signature.name).to eq(nameBefore)
        expect(email_signature.text).to eq(textBefore)
        expect(email_signature.html).to eq(htmlBefore)
      end

    end
  
  end

  context 'deleting signatures' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_signature) { FactoryGirl.create(:email_signature, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should delete the signature' do
        expect(user.email_signatures.count).to eq(1)
        delete "/api/v1/email_signatures/#{email_signature.uid}"
        expect(user.email_signatures.count).to eq(0)
      end
    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT delete the signature' do
        expect(user.email_signatures.count).to eq(1)
        
        delete "/api/v1/email_signatures/#{email_signature.uid}"
        expect(response).to have_http_status($config.http_errors[:email_signature_not_found][:status_code])
        
        expect(user.email_signatures.count).to eq(1)
      end
    end
  end
end
