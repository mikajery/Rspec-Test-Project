require 'rails_helper'

describe Api::V1::EmailThreadsController, :type => :request do
  describe ".show" do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_thread => email_thread) }
    context 'when the user is NOT signed in' do
      before do
        get "/api/v1/email_threads/show/#{email_thread.uid}"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should show a thread' do

        get "/api/v1/email_threads/show/#{email_thread.uid}"
        email_thread_rendered = JSON.parse(response.body)
        validate_email_thread(email_thread, email_thread_rendered)
      end

      it 'renders the api/v1/email_threads/index rabl' do
        expect( get "/api/v1/email_threads/show/#{email_thread.uid}" ).to render_template('api/v1/email_threads/show')
      end

      context "when try to show other thread" do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account) }
        let!(:email_thread_other) { FactoryGirl.create(:email_thread, :email_account => gmail_account_other) }

        it 'responds with the email thread not found status code' do
          get "/api/v1/email_threads/show/#{email_thread_other.uid}"

          expect(response.status).to eq($config.http_errors[:email_thread_not_found][:status_code])
        end

        it 'returns the email thread not found message' do
          get "/api/v1/email_threads/show/#{email_thread_other.uid}"

          expect(response.body).to eq($config.http_errors[:email_thread_not_found][:description])
        end
      end #__End of context "when try to show other thread"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".show"__

  describe ".inbox" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_threads/inbox'
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
      let!(:emails) { FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :last_email_thread_uid => email_thread.id
        }
      }
      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it "finds the last thread" do
          expect(EmailThread).to receive(:find_by)

          get '/api/v1/email_threads/inbox'
        end

        it "responds with 200 status code" do
          get '/api/v1/email_threads/inbox'

          expect(response.status).to eq(200)
        end

        it 'renders the api/v1/email_threads/index rabl' do
          expect( get '/api/v1/email_threads/inbox' ).to render_template('api/v1/email_threads/index')
        end

        context "with no inbox folder" do
          before do
            allow_any_instance_of(GmailAccount).to receive(:inbox_folder).and_return(nil)
          end

          it "renders the empty array" do
            get '/api/v1/email_threads/inbox'

            result = JSON.parse(response.body)

            expect(result).to eq( [] )
          end
        end #__End of context "with no inbox folder"__

        context "with the inbox folder" do
          let!(:gmail_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
          before do
            allow_any_instance_of(GmailAccount).to receive(:inbox_folder).and_return(gmail_label)
            allow(EmailThread).to receive(:find_by).and_return(email_thread)
          end

          it 'gets the sorted paginated threads from the inbox folder' do
            expect_any_instance_of(GmailLabel).to receive(:get_sorted_paginated_threads).with(last_email_thread: email_thread, dir: nil, threads_per_page: 30)

            get '/api/v1/email_threads/inbox', params
          end

          it 'renders the sorted paginated threads' do
            email_threads = [email_thread]
            allow_any_instance_of(GmailLabel).to receive(:get_sorted_paginated_threads).and_return(email_threads)

            get '/api/v1/email_threads/inbox'

            email_threads_stats = JSON.parse(response.body)
            email_threads_stats.each do |email_thread_rendered|
              validate_email_thread(email_thread, email_thread_rendered)
            end
          end
        end #__End of context "with the inbox folder"__
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          get '/api/v1/email_threads/inbox'

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          get '/api/v1/email_threads/inbox'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".inbox"__

  describe ".in_folder" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_threads/in_folder'
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
      let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
      let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
      let!(:email) { FactoryGirl.create(:email, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :folder_id => gmail_label.label_id,
          :last_email_thread_uid => email_thread.uid
        }
      }

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(User).to receive(:gmail_accounts).and_return([gmail_account])
        }

        context "with no email folder" do
          before do
            allow(GmailLabel).to receive(:find_by).and_return(nil)
          end

          it "responds with the email folder not found status code" do
            get '/api/v1/email_threads/in_folder'

            expect(response.status).to eq($config.http_errors[:email_folder_not_found][:status_code])
          end

          it "renders the email folder not found message" do
            get '/api/v1/email_threads/in_folder'

            expect(response.body).to eq($config.http_errors[:email_folder_not_found][:description])
          end
        end #__End of context "with no email folder"__

        context "with the email folder" do
          before do
            allow(GmailLabel).to receive(:find_by).and_return(gmail_label)
          end

          it 'gets the sorted paginated threads from the email folder' do
            expect_any_instance_of(GmailLabel).to receive(:get_sorted_paginated_threads).with(last_email_thread: email_thread, dir: params[:dir], threads_per_page: 30)

            get '/api/v1/email_threads/in_folder', params
          end

          it 'renders the sorted paginated threads' do
            email_threads = [email_thread]
            allow_any_instance_of(GmailLabel).to receive(:get_sorted_paginated_threads).and_return(email_threads)

            get '/api/v1/email_threads/in_folder', params

            email_threads_stats = JSON.parse(response.body)
            email_threads_stats.each do |email_thread_rendered|
              validate_email_thread(email_thread, email_thread_rendered)
            end
          end

          it 'responds with a 200 status code' do
            get '/api/v1/email_threads/in_folder', params

            expect(response.status).to eq(200)
          end

          it 'renders the api/v1/emails/show rabl' do
            expect( get '/api/v1/email_threads/in_folder', params ).to render_template('api/v1/email_threads/index')
          end
        end #__End of context "with the email folder"__
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          get '/api/v1/email_threads/in_folder'

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          get '/api/v1/email_threads/in_folder'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".in_folder"__

  describe ".move_to_folder" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/move_to_folder'
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
      let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
      let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
      let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :email_folder_id => gmail_label.label_id,
          :email_folder_name => gmail_label.name,
          :email_thread_uids => [email_thread.uid]
        }
      }

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(GmailAccount).to receive(:move_emails_to_folder).and_return(gmail_label)
        }

        it 'responds with a 200 status code' do
          allow_any_instance_of(GmailAccount).to receive(:move_emails_to_folder)
          post '/api/v1/email_threads/move_to_folder', params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          allow_any_instance_of(GmailAccount).to receive(:move_emails_to_folder)
          post '/api/v1/email_threads/move_to_folder', params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'moves emails to the folder' do
          expect_any_instance_of(GmailAccount).to receive(:move_emails_to_folder).with(emails, folder_id: params[:email_folder_id], folder_name: params[:email_folder_name])

          post '/api/v1/email_threads/move_to_folder', params
        end

        it 'renders the api/v1/gmail_labels/show rabl' do
          expect( post '/api/v1/email_threads/move_to_folder', params ).to render_template('api/v1/gmail_labels/show')
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          allow_any_instance_of(GmailAccount).to receive(:move_emails_to_folder)
          post '/api/v1/email_threads/move_to_folder', params

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          allow_any_instance_of(GmailAccount).to receive(:move_emails_to_folder)
          post '/api/v1/email_threads/move_to_folder', params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".move_to_folder"__

  describe ".apply_gmail_label" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/apply_gmail_label'
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
      let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
      let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
      let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :gmail_label_id => gmail_label.label_id,
          :gmail_label_name => gmail_label.name,
          :email_thread_uids => [email_thread.uid]
        }
      }

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(User).to receive(:gmail_accounts).and_return([gmail_account])
          allow_any_instance_of(GmailAccount).to receive(:apply_label_to_emails).and_return(gmail_label)
        }

        it 'responds with a 200 status code' do
          allow_any_instance_of(GmailAccount).to receive(:apply_label_to_emails)
          post '/api/v1/email_threads/apply_gmail_label', params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          allow_any_instance_of(GmailAccount).to receive(:apply_label_to_emails)
          post '/api/v1/email_threads/apply_gmail_label', params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'applys labels to the email' do
          expect_any_instance_of(GmailAccount).to receive(:apply_label_to_emails).with(emails, label_id: params[:gmail_label_id], label_name: params[:gmail_label_name])

          post '/api/v1/email_threads/apply_gmail_label', params
        end

        it 'renders the api/v1/gmail_labels/show rabl' do
          expect( post '/api/v1/email_threads/apply_gmail_label', params ).to render_template('api/v1/gmail_labels/show')
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          allow_any_instance_of(GmailAccount).to receive(:apply_label_to_emails)
          post '/api/v1/email_threads/apply_gmail_label', params

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          allow_any_instance_of(GmailAccount).to receive(:apply_label_to_emails)
          post '/api/v1/email_threads/apply_gmail_label', params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".apply_gmail_label"__

  describe ".remove_from_folder" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/remove_from_folder'
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
      let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
      let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
      let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :email_folder_id => gmail_label.label_id,
          :email_thread_uids => [email_thread.uid]
        }
      }

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(User).to receive(:gmail_accounts).and_return([gmail_account])
        }


        it 'responds with a 200 status code' do
          allow_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)
          post '/api/v1/email_threads/remove_from_folder', params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          allow_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)
          post '/api/v1/email_threads/remove_from_folder', params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'removes emails from the folder' do
          expect_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder).with(emails, folder_id: params[:email_folder_id])

          post '/api/v1/email_threads/remove_from_folder', params
        end

      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          allow_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)
          post '/api/v1/email_threads/remove_from_folder', params

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          allow_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)
          post '/api/v1/email_threads/remove_from_folder', params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".remove_from_folder"__

  describe ".trash" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/trash'
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
      let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :email_thread_uids => [email_thread.uid]
        }
      }

      context "when the user has their email account" do
        before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it 'responds with a 200 status code' do
          allow_any_instance_of(GmailAccount).to receive(:trash_emails)
          post '/api/v1/email_threads/trash', params
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          allow_any_instance_of(GmailAccount).to receive(:trash_emails)
          post '/api/v1/email_threads/trash', params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'removes emails from the folder' do
          expect_any_instance_of(GmailAccount).to receive(:trash_emails)

          post '/api/v1/email_threads/trash', params
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          allow_any_instance_of(GmailAccount).to receive(:trash_emails)
          post '/api/v1/email_threads/trash', params

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          allow_any_instance_of(GmailAccount).to receive(:trash_emails)
          post '/api/v1/email_threads/trash', params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".trash"__

  describe ".retrieve" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/retrieve'
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
      let!(:email_threads) { FactoryGirl.create_list(:email_thread, 2, :email_account => gmail_account) }
      let!(:params) {
        {
          :email_thread_uids => email_threads.collect(&:uid)
        }
      }
      before do
        FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_thread => email_threads.first)
        FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_thread => email_threads.last)
      end

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(User).to receive(:gmail_accounts).and_return([gmail_account])
        }

        it 'sorts the email threads' do
          post '/api/v1/email_threads/retrieve', params

          email_threads_stats = JSON.parse(response.body)

          expect( email_threads_stats.first["uid"].to_i ).to be <  email_threads_stats.last["uid"].to_i
        end

        it 'renders the sorted threads' do
          post '/api/v1/email_threads/retrieve', params

          email_threads_stats = JSON.parse(response.body)

          validate_email_thread(email_threads.first, email_threads_stats.first)
          validate_email_thread(email_threads.last, email_threads_stats.last)
        end

        it 'responds with a 200 status code' do
          post '/api/v1/email_threads/retrieve', params

          expect(response.status).to eq(200)
        end

        it 'renders the api/v1/email_threads/index rabl' do
          expect( post '/api/v1/email_threads/retrieve', params ).to render_template('api/v1/email_threads/index')
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          post '/api/v1/email_threads/retrieve'

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          post '/api/v1/email_threads/retrieve'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".retrieve"__

  describe ".snooze" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_threads/snooze'
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
      let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :email_thread => email_thread) }
      let!(:params) {
        {
          :email_thread_uids => [email_thread.uid],
          :minutes => "12"
        }
      }

      context "when the user has their email account" do
        before {
          post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
          allow_any_instance_of(User).to receive(:gmail_accounts).and_return([gmail_account])
          allow_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)
        }

        it 'responds with a 200 status code' do
          post '/api/v1/email_threads/snooze', params

          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          post '/api/v1/email_threads/snooze', params
          result = JSON.parse(response.body)
          expect( result ).to eq( {} )
        end

        it 'removes emails from the folder' do
          expect_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder)

          post '/api/v1/email_threads/snooze', params
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          post '/api/v1/email_threads/snooze', params

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          post '/api/v1/email_threads/snooze', params

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".snooze"__
end
