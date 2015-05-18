require 'rails_helper'

describe Api::V1::EmailAccountsController, :type => :request do
  describe ".send_email" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/send_email'
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
      let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
      let!(:params) {
        {
        	:tos => nil,
        	:ccs => nil,
        	:bccs => nil,
        	:subject => nil,
        	:html_part => nil,
        	:text_part => nil,
        	:email_in_reply_to_uid => nil,
        	:tracking_enabled => 'True',
        	:bounce_back_enabled => 'True',
        	:bounce_back_time => nil,
        	:bounce_back_type => nil,
        	:attachment_s3_keys => nil
        }
      }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      before do
        @emails = Email.all
        allow_any_instance_of(GmailAccount).to receive(:delay).and_return( @emails )
        allow(@emails).to receive(:send_email)
      end

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/send_email', params
        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        post '/api/v1/email_accounts/send_email', params
        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end

      it 'sends email on the background' do
        post '/api/v1/email_accounts/send_email', params

        expect(@emails).to have_received(:send_email).with( params[:tos], params[:ccs], params[:bccs],
                                                            params[:subject], params[:html_part], params[:text_part],
                                                            params[:email_in_reply_to_uid],
                                                            params[:tracking_enabled].downcase == 'true',
                                                            params[:bounce_back_enabled].downcase == 'true', params[:bounce_back_time], params[:bounce_back_type],
                                                            params[:attachment_s3_keys])
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_email"__

  describe ".send_email_delayed" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/send_email_delayed'
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
      let!(:params) {
        {
          :tos => "tos",
          :ccs => "ccs",
          :bccs => "bccs",
          :subject => "subject",
          :html_part => "html part",
          :text_part => "text part",
          :email_in_reply_to_uid => "reply-to-uid",
          :tracking_enabled => true,
          :bounce_back_enabled => 'True',
          :bounce_back_time => "2015-03-06 07:26:05.607070004 +0100",
          :bounce_back_type => "bounce back type",
          :attachment_s3_keys => "s3-keys"
        }
      }

      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/send_email_delayed', params
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/delayed_emails/show rabl' do            
        expect( post '/api/v1/email_accounts/send_email_delayed', params ).to render_template('api/v1/delayed_emails/show')
      end

      it 'creates new DelayedEmail with the params' do
        delayed_email = DelayedEmail.new
        allow(DelayedEmail).to receive(:new) { delayed_email }
        

        post '/api/v1/email_accounts/send_email_delayed', params

        expect( delayed_email.email_account ).to eq(gmail_account)
        expect( delayed_email.tos ).to eq(params[:tos])
        expect( delayed_email.ccs ).to eq(params[:ccs])
        expect( delayed_email.bccs ).to eq(params[:bccs])
        expect( delayed_email.subject ).to eq(params[:subject])
        expect( delayed_email.html_part ).to eq(params[:html_part])
        expect( delayed_email.text_part ).to eq(params[:text_part])
        expect( delayed_email.email_in_reply_to_uid ).to eq(params[:email_in_reply_to_uid])
        expect( delayed_email.tracking_enabled ).to eq(params[:tracking_enabled])
        expect( delayed_email.bounce_back ).to be(true)
        expect( delayed_email.bounce_back_time ).to eq(params[:bounce_back_time])
        expect( delayed_email.bounce_back_type ).to eq(params[:bounce_back_type])
        expect( delayed_email.attachment_s3_keys ).to eq(params[:attachment_s3_keys])
        
      end

      context "with the draft_id" do
        before do
          params[:draft_id] = "draft-id"
        end

        it 'deletes the draft' do
          expect_any_instance_of(GmailAccount).to receive(:delete_draft)

          post '/api/v1/email_accounts/send_email_delayed', params
        end
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_email_delayed"__

  describe ".sync" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/sync'
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
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/sync'
        expect(response.status).to eq(200)
      end

      it 'queues the sync account' do
        expect_any_instance_of(GmailAccount).to receive(:queue_sync_account)
        post '/api/v1/email_accounts/sync'
      end

      it 'returns the last sync time' do
        gmail_account.last_sync_at = Time.now
        gmail_account.save!
        post '/api/v1/email_accounts/sync'
        expect(response.body).to eq(gmail_account.last_sync_at.to_json)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".sync"__

  describe ".search_threads" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/search_threads'
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
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        post '/api/v1/email_accounts/search_threads'
        expect(response.status).to eq(200)
      end

      it 'renders the search_threads rabl' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        expect( post '/api/v1/email_accounts/search_threads' ).to render_template(:search_threads)
      end

      it 'has "next_page_token", "email_threads" keys' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        post '/api/v1/email_accounts/search_threads'
        search_threads = JSON.parse(response.body)

        expect( search_threads.keys.include?("next_page_token") ).to be(true)
        expect( search_threads.keys.include?("email_threads") ).to be(true)
      end

      context 'no email threads' do
        before do
          allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        end

        it 'returns the empty array' do
          post '/api/v1/email_accounts/search_threads'
          email_threads = JSON.parse(response.body)["email_threads"]
          expect( email_threads ).to eq( [] )
        end
      end

      context "with email threads" do
        let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
        let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
        let!(:email) { FactoryGirl.create_list(:email, 2, email_thread: email_thread)}
        let!(:next_page_token) { 2 }
        before do
          @email_thread_uids = EmailThread.pluck(:uid)
          allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([@email_thread_uids, next_page_token])

          post '/api/v1/email_accounts/search_threads'
        end

        it 'returns the next page token' do
          expect( JSON.parse(response.body)["next_page_token"] ).to eq( next_page_token )
        end

        it 'returns the email threads' do
          email_threads_stats = JSON.parse(response.body)["email_threads"]
          
          email_threads_stats.each do |email_thread_rendered|
            validate_email_thread(email_thread, email_thread_rendered)
          end
          # expect( email_threads.count ).to eq()
        end
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".search_threads"__

  describe ".create_draft" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/drafts'
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
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        post '/api/v1/email_accounts/drafts'
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/emails/show rabl' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        expect( post '/api/v1/email_accounts/drafts' ).to render_template('api/v1/emails/show')
      end

      it 'returns the email' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        post '/api/v1/email_accounts/drafts'

        email_rendered = JSON.parse(response.body)
        validate_email(email, email_rendered)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create_draft"__

  describe ".update_draft" do
    context 'when the user is NOT signed in' do 
      before do
        put '/api/v1/email_accounts/drafts'
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
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        put '/api/v1/email_accounts/drafts'
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/emails/show rabl' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        expect( put '/api/v1/email_accounts/drafts' ).to render_template('api/v1/emails/show')
      end

      it 'returns the email' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        put '/api/v1/email_accounts/drafts'

        email_rendered = JSON.parse(response.body)
        validate_email(email, email_rendered)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".update_draft"__

  describe ".send_draft" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/send_draft'
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
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)
        post '/api/v1/email_accounts/send_draft'
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/emails/show rabl' do
        allow_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)
        expect( post '/api/v1/email_accounts/send_draft' ).to render_template('api/v1/emails/show')
      end

      it 'returns the email' do
        allow_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)
        post '/api/v1/email_accounts/send_draft'

        email_rendered = JSON.parse(response.body)
        validate_email(email, email_rendered)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_draft"__

  describe ".delete_draft" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/delete_draft'
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
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:delete_draft)
        post '/api/v1/email_accounts/delete_draft'
        expect(response.status).to eq(200)
      end

      it 'deletes the draft' do
        expect_any_instance_of(GmailAccount).to receive(:delete_draft)

        post '/api/v1/email_accounts/delete_draft'
      end

      it 'returns the empty hash' do
        allow_any_instance_of(GmailAccount).to receive(:delete_draft)
        post '/api/v1/email_accounts/delete_draft'

        result = JSON.parse(response.body)

        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".delete_draft"__

  describe ".cleaner_report" do
    context 'when the user is NOT signed in' do 
      before do
        get '/api/v1/email_accounts/cleaner_report'
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
      let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do        
        get '/api/v1/email_accounts/cleaner_report'
        expect(response.status).to eq(200)
      end

      it 'renders the cleaner_report rabl' do
        expect( get '/api/v1/email_accounts/cleaner_report' ).to render_template(:cleaner_report)
      end

      it 'returns the number of the auto filed emails' do
        get '/api/v1/email_accounts/cleaner_report'
        cleaner_report_stats = JSON.parse(response.body)
        expect( cleaner_report_stats["num_auto_filed_emails"] ).to eq(1)
      end

      it 'returns the auto filed emails' do
        get '/api/v1/email_accounts/cleaner_report'
        cleaner_report_stats = JSON.parse(response.body)
        cleaner_report_stats["auto_filed_emails"].each do |email_rendered|
          validate_email(email, email_rendered)
        end
      end

      context "no inbox label" do
        it 'returns 0 num_important_emails' do
          get '/api/v1/email_accounts/cleaner_report'
          cleaner_report_stats = JSON.parse(response.body)
          expect( cleaner_report_stats["num_important_emails"] ).to eq(0)
        end

        it 'returns empty important_emails' do
          get '/api/v1/email_accounts/cleaner_report'
          cleaner_report_stats = JSON.parse(response.body)
          expect( cleaner_report_stats["important_emails"] ).to eq([])
        end
      end #__End of context "no inbox label"__

      context "with inbox label" do
        let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
        before do
          @emails = Email.all
          allow_any_instance_of(GmailLabel).to receive(:emails).and_return(@emails)
          allow(@emails).to receive(:where).and_return(@emails)
        end

        it 'returns the number of the important emails' do
          get '/api/v1/email_accounts/cleaner_report'
          cleaner_report_stats = JSON.parse(response.body)
          expect( cleaner_report_stats["num_important_emails"] ).to eq(1)
        end

        it 'returns the important emails' do
          get '/api/v1/email_accounts/cleaner_report'
          cleaner_report_stats = JSON.parse(response.body)
          cleaner_report_stats["important_emails"].each do |email_rendered|
            validate_email(email, email_rendered)
          end
        end
      end #__End of context "with inbox label"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".cleaner_report"__

  describe ".apply_cleaner" do
    context 'when the user is NOT signed in' do 
      before do
        post '/api/v1/email_accounts/apply_cleaner'
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
      let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      before do
        @emails = Email.all
      end
      it 'responds with a 200 status code' do        
        post '/api/v1/email_accounts/apply_cleaner'
        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        post '/api/v1/email_accounts/apply_cleaner'
        apply_cleaner_stats = JSON.parse(response.body)
        expect(apply_cleaner_stats).to eq({})
      end

      it 'updates all the email' do
        allow_any_instance_of(GmailAccount).to receive(:emails).and_return( @emails )
        allow(@emails).to receive(:where).and_return( @emails )
        allow(@emails).to receive(:update_all)

        post '/api/v1/email_accounts/apply_cleaner'

        expect(@emails).to have_received(:update_all).with(:queued_auto_file => true)
      end

      it 'applys the cleaner' do
        allow_any_instance_of(GmailAccount).to receive(:delay).and_return( @emails )
        allow(@emails).to receive(:apply_cleaner)

        post '/api/v1/email_accounts/apply_cleaner'

        expect(@emails).to have_received(:apply_cleaner)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".apply_cleaner"__
end
