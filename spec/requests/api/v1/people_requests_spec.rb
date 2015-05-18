require 'rails_helper'

describe Api::V1::PeopleController, :type => :request do
  describe ".recent_thread_subjects" do
    context 'when the user is NOT signed in' do 
      before do
        post "/api/v1/people/recent_thread_subjects"
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
      let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
      let!(:email) { FactoryGirl.create(:email) }
      let!(:params) {
        {:email => email.id.to_s}
      }

      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it "gets the recent thread subjects" do
          expect_any_instance_of(GmailAccount).to receive(:recent_thread_subjects).with(params[:email])

          post "/api/v1/people/recent_thread_subjects", params
        end

        it "responds with 200 status code" do
          recent_thread_subjects = {:email_thread_uid => "uid", :subject => "subject"}
          allow_any_instance_of(GmailAccount).to receive(:recent_thread_subjects).and_return( recent_thread_subjects )

          post "/api/v1/people/recent_thread_subjects", params

          expect(response.status).to eq(200)
        end

        it 'renders the recent thread subjects' do
          recent_thread_subjects = {:email_thread_uid => "uid", :subject => "subject"}
          allow_any_instance_of(GmailAccount).to receive(:recent_thread_subjects).and_return( recent_thread_subjects )

          post "/api/v1/people/recent_thread_subjects", params

          thread_subjects = JSON.parse(response.body)
          expect( thread_subjects["email_thread_uid"] ).to eq( recent_thread_subjects[:email_thread_uid] )
          expect( thread_subjects["subject"] ).to eq( recent_thread_subjects[:subject] )
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          post "/api/v1/people/recent_thread_subjects"

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          post "/api/v1/people/recent_thread_subjects"

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".recent_thread_subjects"__

  describe ".search" do
    context 'when the user is NOT signed in' do 
      let!(:query) { "query" }
      before do
        get "/api/v1/people/search/#{query}"
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
      let!(:people) { FactoryGirl.create_list(:person, 10, email_account: gmail_account) }
      
      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it 'renders the api/v1/people/index rabl' do 
          query = "Person"           
          expect( get "/api/v1/people/search/#{query}" ).to render_template('api/v1/people/index')
        end

        it "search people with the similar name" do
          query = "Person"
          get "/api/v1/people/search/#{query}"

          result = JSON.parse(response.body)
          result.each do |obj|
            expect( obj["name"].include?(query) ).to be(true)
          end
        end

        it "search people with the similar address" do
          query = "bar.com"
          get "/api/v1/people/search/#{query}"

          result = JSON.parse(response.body)
          result.each do |obj|
            expect( obj["email_address"].include?(query) ).to be(true)
          end
        end

        it "renders only 6 limited people" do
          query = "bar.com"
          get "/api/v1/people/search/#{query}"

          result = JSON.parse(response.body)
          expect( result.count ).to eq(6)
        end

        it "responds with 200 status code" do
          query = "bar.com"
          get "/api/v1/people/search/#{query}"

          expect(response.status).to eq(200)
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        let!(:query) { "query" }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          get "/api/v1/people/search/#{query}"

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          get "/api/v1/people/search/#{query}"

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".search"__

  describe ".search" do
    context 'when the user is NOT signed in' do 
      let!(:query) { "query" }
      before do
        get "/api/v1/people/search/#{query}"
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
      let!(:query) { "query" }

      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        get "/api/v1/people/search/#{query}"
        expect(response.status).to eq(200)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".search"__
end
