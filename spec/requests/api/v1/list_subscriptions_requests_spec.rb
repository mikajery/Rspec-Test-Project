require 'rails_helper'

describe Api::V1::ListSubscriptionsController, :type => :request do
  describe ".index" do
    context 'when the user is NOT signed in' do 
      before do
        get '/api/v1/list_subscriptions'
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

      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it "responds with 200 status code" do
          get '/api/v1/list_subscriptions'

          expect(response.status).to eq(200)
        end

        it 'renders the api/v1/list_subscriptions/index rabl' do            
          expect( get '/api/v1/list_subscriptions' ).to render_template('api/v1/list_subscriptions/index')
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          get '/api/v1/list_subscriptions'

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          get '/api/v1/list_subscriptions'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe ".unsubscribe" do
    context 'when the user is NOT signed in' do 
      before do
        delete '/api/v1/list_subscriptions/unsubscribe'
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
      before do
        @list_subscription = FactoryGirl.build(:list_subscription)
        @list_subscription.email_account = gmail_account
        @list_subscription.unsubscribed = false
        @list_subscription.unsubscribe_delayed_job_id = nil
        @list_subscription.save!

        @params = {
          :list_id => @list_subscription.list_id,
          :list_name => @list_subscription.list_name,
          :list_domain => @list_subscription.list_domain
        }
      end

      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it 'responds with a 200 status code' do
          delete '/api/v1/list_subscriptions/unsubscribe', @params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          delete '/api/v1/list_subscriptions/unsubscribe', @params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'unsubscribes the list' do
          delete '/api/v1/list_subscriptions/unsubscribe', @params
          @list_subscription.reload
          expect( @list_subscription.unsubscribe_delayed_job_id ).not_to be(nil)
          expect( @list_subscription.unsubscribed ).to be(true)
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          delete '/api/v1/list_subscriptions/unsubscribe', @params
          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          delete '/api/v1/list_subscriptions/unsubscribe', @params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".unsubscribe"__

  describe ".resubscribe" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/list_subscriptions/resubscribe'
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
      before do
        @list_subscription = FactoryGirl.build(:list_subscription)
        @list_subscription.email_account = gmail_account
        @list_subscription.unsubscribed = true
        @list_subscription.save!

        @params = {
          :list_id => @list_subscription.list_id,
          :list_name => @list_subscription.list_name,
          :list_domain => @list_subscription.list_domain
        }
      end

      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it 'responds with a 200 status code' do
          post '/api/v1/list_subscriptions/resubscribe', @params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          post '/api/v1/list_subscriptions/resubscribe', @params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'resubscribe the all the unsubscribed list' do
          expect_any_instance_of(ListSubscription).to receive(:resubscribe)

          post '/api/v1/list_subscriptions/resubscribe', @params
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          post '/api/v1/list_subscriptions/resubscribe'
          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          post '/api/v1/list_subscriptions/resubscribe'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".resubscribe"__
end
