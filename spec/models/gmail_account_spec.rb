# == Schema Information
#
# Table name: gmail_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  google_id              :text
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  created_at             :datetime
#  updated_at             :datetime
#  sync_delayed_job_id    :integer
#

require 'rails_helper'
require 'stringio'

describe GmailAccount, :type => :model do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let(:original_data) { "original gmail data" }
  let(:encoded_data) { Base64.urlsafe_encode64(original_data) }
  let(:gmail_data) { {:raw => encoded_data} }
  let(:google_o_auth2_token) { FactoryGirl.create(:google_o_auth2_token) }

  # relationship
  it { should belong_to :user }

  it { should have_one(:google_o_auth2_token).dependent(:destroy) }

  it { should have_many(:email_threads).dependent(:destroy) }
  it { should have_many(:emails).dependent(:destroy) }
  it { should have_many(:email_attachments) }
  it { should have_many(:people).dependent(:destroy) }
  it { should have_many(:gmail_labels).dependent(:destroy) }
  it { should have_many(:sync_failed_emails).dependent(:destroy) }
  it { should have_many(:delayed_emails).dependent(:destroy) }
  it { should have_many(:email_trackers).dependent(:destroy) }
  it { should have_many(:email_tracker_recipients) }
  it { should have_many(:email_tracker_views) }
  it { should have_many(:list_subscriptions).dependent(:destroy) }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:google_id).of_type(:text)  }
  it { should have_db_column(:email).of_type(:text)  }
  it { should have_db_column(:verified_email).of_type(:boolean)  }
  it { should have_db_column(:sync_started_time).of_type(:datetime)  }
  it { should have_db_column(:last_history_id_synced).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }
  it { should have_db_column(:sync_delayed_job_id).of_type(:integer)  }

  # indexes
  it { should have_db_index(:email) }
  it { should have_db_index(:google_id).unique(true) }
  it { should have_db_index([:user_id, :email]).unique(true) }

  # validation
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:google_id) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:verified_email) }

  # static variables
  describe "::MESSAGE_BATCH_SIZE" do
    it 'returns 100' do
      expect( GmailAccount::MESSAGE_BATCH_SIZE ).to eq( 100 )
    end
  end

  describe "::DRAFTS_BATCH_SIZE" do
    it 'returns 100' do
      expect( GmailAccount::DRAFTS_BATCH_SIZE ).to eq( 100 )
    end
  end

  describe "::HISTORY_BATCH_SIZE" do
    it 'returns 100' do
      expect( GmailAccount::HISTORY_BATCH_SIZE ).to eq( 100 )
    end
  end

  describe "::SEARCH_RESULTS_PER_PAGE" do
    it 'returns 50' do
      expect( GmailAccount::SEARCH_RESULTS_PER_PAGE ).to eq( 50 )
    end
  end

  describe "::NUM_SYNC_DYNOS" do
    it 'returns 3' do
      expect( GmailAccount::NUM_SYNC_DYNOS ).to eq( 3 )
    end
  end

  describe "::SCOPES" do
    it 'returns the array of the urls' do
      expected = ["https://mail.google.com/",
                  "https://www.googleapis.com/auth/userinfo.email",
                  "https://www.googleapis.com/auth/gmail.readonly",
                  "https://www.googleapis.com/auth/gmail.compose",
                  "https://www.googleapis.com/auth/gmail.modify"]

      expect( GmailAccount::SCOPES ).to eq( expected )
    end
  end

  # class methods
  describe "#mime_data_from_gmail_data" do

    it 'returns the mime data of the gmail data' do
      expect( GmailAccount.mime_data_from_gmail_data(gmail_data) ).to eq( original_data )
    end
  end #__End of describe "#mime_data_from_gmail_data"__

  describe "#email_raw_from_gmail_data" do

    it 'returns the raw email from the gmail data' do
      expected = true

      allow(Email).to receive(:email_raw_from_mime_data) { expected }

      expect( GmailAccount.email_raw_from_gmail_data(gmail_data) ).to eq( expected )
    end
  end #__End of describe "#email_raw_from_gmail_data"__

  describe "#email_from_gmail_data" do

    let(:email) { FactoryGirl.create(:email) }

    it 'returns the email' do
      allow(Email).to receive(:email_from_mime_data) { email }

      expect( GmailAccount.email_from_gmail_data(gmail_data) ).to eq( email )
    end

    it 'saves the id of the gmail data to the uid field of the email' do
      gmail_data['id'] = rand(10)

      allow(Email).to receive(:email_from_mime_data) { email }

      result_email = GmailAccount.email_from_gmail_data(gmail_data)

      expect( result_email.uid ).to eq( gmail_data['id'].to_s )
    end

    it 'saves the snippet of the gmail data to the snippet field of the email' do
      gmail_data['snippet'] = FFaker::Lorem.sentence

      allow(Email).to receive(:email_from_mime_data) { email }

      result_email = GmailAccount.email_from_gmail_data(gmail_data)

      expect( result_email.snippet ).to eq( gmail_data['snippet'] )
    end

  end #__End of describe "#email_from_gmail_data"__

  describe "#init_email_from_gmail_data" do
    let(:email) { FactoryGirl.create(:email) }

    it 'saves the id of the gmail data to the uid field of the email' do
      gmail_data['id'] = rand(10)

      GmailAccount.init_email_from_gmail_data(email, gmail_data)

      expect( email.uid ).to eq( gmail_data['id'].to_s )
    end

    it 'saves the snippet of the gmail data to the snippet field of the email' do
      gmail_data['snippet'] = FFaker::Lorem.sentence

      GmailAccount.init_email_from_gmail_data(email, gmail_data)

      expect( email.snippet ).to eq( gmail_data['snippet'] )
    end
  end #__End of describe "#init_email_from_gmail_data"__

  describe "#get_userinfo" do
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }

    it 'returns the user info from the client' do
      o_auth2_client = Google::OAuth2Client.new(api_client)

      user_info = { :name => "user name" }

      allow(Google::OAuth2Client).to receive(:new) { o_auth2_client }
      allow(o_auth2_client).to receive(:userinfo_get) { user_info }

      expect( GmailAccount.get_userinfo(api_client) ).to eq( user_info )
    end
  end #__End of describe "#get_userinfo"__

  # methods
  describe ".gmail_client" do

    it 'returns the gmail client' do
      gmail_client = Google::GmailClient.new(google_o_auth2_token.api_client)
      gmail_account = google_o_auth2_token.google_api

      allow(Google::GmailClient).to receive(:new) { gmail_client }

      expect( gmail_account.gmail_client ).to eq( gmail_client )
    end
  end #__End of describe ".gmail_client"__

  describe ".init_email_from_gmail_data" do
    let(:email) { FactoryGirl.create(:email) }

    it 'saves the id of the gmail data to the uid field of the email' do
      gmail_data['id'] = rand(10)

      gmail_account.init_email_from_gmail_data(email, gmail_data)

      expect( email.uid ).to eq( gmail_data['id'].to_s )
    end

    it 'saves the snippet of the gmail data to the snippet field of the email' do
      gmail_data['snippet'] = FFaker::Lorem.sentence

      gmail_account.init_email_from_gmail_data(email, gmail_data)

      expect( email.snippet ).to eq( gmail_data['snippet'] )
    end

    it 'saves itself to the email_account field of the email' do
      gmail_account.init_email_from_gmail_data(email, gmail_data)

      expect( email.email_account ).to eq( gmail_account )
    end
  end #__End of describe ".init_email_from_gmail_data"__

  describe ".gmail_data_from_gmail_id" do
    let(:gmail_id) { "gmail-id" }

    it 'returns the gmail data from the gmail id' do
      gmail_client = gmail_account.gmail_client
      expected = true

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:messages_get) { expected }

      expect( gmail_account.gmail_data_from_gmail_id(gmail_id) ).to eq( expected )
    end
  end #__End of describe ".gmail_data_from_gmail_id"__

  describe ".mime_data_from_gmail_id" do
    let(:gmail_id) { "gmail-id" }

    it 'returns the mime data from the gmail id' do
      expected = true

      allow(gmail_account).to receive(:gmail_data_from_gmail_id) { expected }
      allow(GmailAccount).to receive(:mime_data_from_gmail_data) { expected }

      expect( gmail_account.mime_data_from_gmail_id(gmail_id) ).to eq( expected )
    end
  end #__End of describe ".mime_data_from_gmail_id"__

  describe ".email_raw_from_gmail_id" do
    let(:gmail_id) { "gmail-id" }

    it 'returns the raw email from the gmail id' do
      expected = true

      allow(gmail_account).to receive(:mime_data_from_gmail_id) { expected }
      allow(Email).to receive(:email_raw_from_mime_data) { expected }

      expect( gmail_account.email_raw_from_gmail_id(gmail_id) ).to eq( expected )
    end
  end #__End of describe ".email_raw_from_gmail_id"__

  describe ".email_from_gmail_id" do
    let(:gmail_id) { "gmail-id" }
    let(:email) { FactoryGirl.create(:email) }

    before(:each) {
      gmail_data['id'] = rand(10)
      gmail_data['snippet'] = FFaker::Lorem.sentence

      allow(gmail_account).to receive(:gmail_data_from_gmail_id) { gmail_data }
      allow(GmailAccount).to receive(:email_from_gmail_data) { email }


    }

    it 'returns the email from the gmail id' do

      expect( gmail_account.email_from_gmail_id(gmail_id).class ).to eq( Email )
    end

    it 'saves the gmail account to the email account field of the email' do

      gmail_account.email_from_gmail_id(gmail_id)

      expect( email.email_account ).to eq( gmail_account )
    end

    it 'saves the id of the gmail data to the uid field of the email' do

      gmail_account.email_from_gmail_id(gmail_id)

      expect( email.uid ).to eq( gmail_data['id'].to_s )
    end

    it 'saves the snippet of the gmail data to the snippet field of the email' do

      gmail_account.email_from_gmail_id(gmail_id)

      expect( email.snippet ).to eq( gmail_data['snippet'] )
    end
  end #__End of describe ".email_from_gmail_id"__

  describe '.inbox_folder' do
    let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }

    it 'returns the inbox folder' do
      expect( gmail_account.inbox_folder ).to eq( inbox_label )
    end
  end #__End of describe ".inbox_folder"__

  describe '.sent_folder' do
    let!(:sent_label) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }

    it 'returns the sent folder' do
      expect( gmail_account.sent_folder ).to eq( sent_label )
    end
  end #__End of describe ".sent_folder"__

  describe '.drafts_folder' do
    let!(:drafts_label) { FactoryGirl.create(:gmail_label_drafts, :gmail_account => gmail_account) }

    it 'returns the drafts folder' do
      expect( gmail_account.drafts_folder ).to eq( drafts_label )
    end
  end #__End of describe ".drafts_folder"__

  describe '.trash_folder' do
    let!(:trash_label) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }

    it 'returns the trash folder' do
      expect( gmail_account.trash_folder ).to eq( trash_label )
    end
  end #__End of describe ".trash_folder"__

  describe '.set_last_history_id_synced' do
    it 'updates the last_history_id_synced' do
      last_history_id_synced = "test history id"

      gmail_account.set_last_history_id_synced(last_history_id_synced)

      gmail_account.reload

      expect( gmail_account.last_history_id_synced ).to eq( last_history_id_synced )
    end
  end #__End of describe ".set_last_history_id_synced"__

  describe '.delete_o_auth2_token' do
    context "when the google_o_auth2_token exists" do
      it 'destroys the delete_o_auth2_token' do

        gmail_account.delete_o_auth2_token

        expect( gmail_account.google_o_auth2_token ).to be(nil)
      end
    end #__End of context "when the google_o_auth2_token exists"__

  end #__End of describe ".delete_o_auth2_token"__

  describe ".refresh_user_info" do
    let(:userinfo_data) {
      { 'id' => "google-id",
        'email' => "google-email",
        'verified_email' => true
      }
    }

    context "when the do_save is true" do

      before(:each) {
        allow(GmailAccount).to receive(:get_userinfo) { userinfo_data }
        gmail_account.refresh_user_info
        gmail_account.reload
      }

      it 'updates the google_id to the user info id' do

        expect( gmail_account.google_id ).to eq( userinfo_data['id'] )
      end

      it 'updates the email to the user info email' do

        expect( gmail_account.email ).to eq( userinfo_data['email'] )
      end

      it 'updates the verified_email to the user info verified_email' do

        expect( gmail_account.verified_email ).to eq( userinfo_data['verified_email'] )
      end
    end #__End of context "when the do_save is true"__

    context "when the do_save is false" do
      before(:each) {
        userinfo_data['verified_email'] = false
        allow(GmailAccount).to receive(:get_userinfo) { userinfo_data }
        gmail_account.refresh_user_info(nil, false)
        gmail_account.reload
      }

      it 'does not update the google_id to the user info id' do

        expect( gmail_account.google_id ).not_to eq( userinfo_data['id'] )
      end

      it 'does not update the email to the user info email' do

        expect( gmail_account.email ).not_to eq( userinfo_data['email'] )
      end

      it 'does not update the verified_email to the user info verified_email' do

        expect( gmail_account.verified_email ).not_to eq( userinfo_data['verified_email'] )
      end
    end #__End of context "when the do_save is false"__
  end #__End of describe ".refresh_user_info"__

  describe ".recent_thread_subjects" do
    let(:threads_list_data) {
      {
        'threads' => [
          {'id' => "thread-id"}
        ]
      }
    }
    let(:email_address) { FFaker::Internet.email }

    context "when the Google::APIClient::BatchRequest is failed" do
      it 'returns the empty array' do
        gmail_client = gmail_account.gmail_client

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(gmail_client).to receive(:threads_list) { threads_list_data }

        expect( gmail_account.recent_thread_subjects(email_address) ).to eq( [] )
      end
    end

    context "when the Google::APIClient::BatchRequest is not failed" do
      before do
        allow_any_instance_of(Google::APIClient::Result).to receive(:error?).and_return(false)
      end

      context "when the payload headers of the batch request exists" do
        let!(:gmail_data) {
          {
            'messages' => 
              [
                {
                  'payload' => {
                    'headers' => [{ 'value' => 'MESSAGE VALUE' }]
                  }
                }
              ],
            'id' => 'gmail-id'
          }
        }

        before do
          call = gmail_account.gmail_client.threads_get_call('me', "thread-id", format: 'metadata', metadataHeaders: 'subject')
          allow_any_instance_of(Google::GmailClient).to receive(:threads_get_call).and_return(call)
          allow_any_instance_of(Google::APIClient::Result).to receive(:data).and_return(gmail_data)
        end
        
        it 'returns the thread subjects' do
          gmail_client = gmail_account.gmail_client

          allow(gmail_account).to receive(:gmail_client) { gmail_client }
          allow(gmail_client).to receive(:threads_list) { threads_list_data }
          
          expect( gmail_account.recent_thread_subjects(email_address) ).to eq( [{:email_thread_uid=>"gmail-id", :subject=>"MESSAGE VALUE"}] )
          
        end
      end #__End of context "when the payload headers of the batch request exists"__
    end #__End of context "when the Google::APIClient::BatchRequest is not failed"__
  end #__End of describe ".recent_thread_subjects"__

  describe ".find_or_create_label" do
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let!(:label_id) { "label-id" }
    let!(:label_name) { "label-name" }

    context "when the label_id is valid" do
      it 'returns the gmail label by the label_id' do
        allow(GmailLabel).to receive(:find_by).with(:gmail_account => gmail_account, :label_id => label_id) { gmail_label }

        expect( gmail_account.find_or_create_label(label_id: label_id, label_name: label_name) ).to eq( gmail_label )
      end
    end

    context "when the label_id is invalid" do
      context "when the label_name is valid" do
        it 'returns the gmail label by the label_name' do
          allow(GmailLabel).to receive(:find_by).with(:gmail_account => gmail_account, :name => label_name) { gmail_label }

          expect( gmail_account.find_or_create_label(label_id: nil, label_name: label_name) ).to eq( gmail_label )
        end
      end

      context "when the label_name is invalid" do
        let(:label_data) { true }
        before do
          allow(GmailLabel).to receive(:find_by).and_return(nil)
        end

        context "when the label_id is not 'TRASH'" do
          before do
            $config.gmail_live = true
          end

          it 'creates new gmail label by the gmail client' do
            gmail_client = gmail_account.gmail_client

            allow(gmail_account).to receive(:gmail_client) { gmail_client }
            allow(gmail_client).to receive(:labels_create) { label_data }
            allow(gmail_account).to receive(:sync_label_data) { gmail_label }

            expect( gmail_account.find_or_create_label(label_id: nil, label_name: nil) ).to eq( gmail_label )
          end
        end

        context "when the label_id is 'TRASH'" do

          it 'creates new gmail label with the label_type value "system"' do
            result = gmail_account.find_or_create_label(label_id: 'TRASH', label_name: label_name)
            
            expect( result.gmail_account ).to eq( gmail_account )
            expect( result.label_id ).to eq( 'TRASH' )
            expect( result.name ).to eq( label_name )
            expect( result.label_type ).to eq( 'system' )
          end
        end
      end #__End of context "when the label_name is invalid"__
    end #__End of context "when the label_id is invalid"__

    context "when the Google::APIClient::ServerError raises" do
      it 'retrys to attempt the Google API' do
        allow(GmailLabel).to receive(:find_by){
          raise Google::APIClient::ServerError
        }

        allow(gmail_account).to receive(:sync_labels) { true }

        expect { gmail_account.find_or_create_label(label_id: label_id, label_name: label_name) }.to raise_error
      end
    end
  end #__End of describe ".find_or_create_label"__

  describe ".emails_set_seen" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread) }
    let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread) }

    context "when the seen is true" do
      it 'removes emails from the folder' do
        allow(gmail_account).to receive(:remove_emails_from_folder)

        gmail_account.emails_set_seen(Email.where(id: email), true)

        expect( gmail_account ).to have_received(:remove_emails_from_folder)
      end
    end

    context "when the seen is false" do
      it 'applies the label to the emails' do
        allow(gmail_account).to receive(:apply_label_to_emails)

        gmail_account.emails_set_seen(Email.where(id: email), false)

        expect( gmail_account ).to have_received(:apply_label_to_emails)
      end
    end

    it 'updates the seen' do
      gmail_account.emails_set_seen(Email.where(id: email), true)

      expect( Email.where(id: email).first.seen ).to be(true)
    end

    it 'updates num_unread_threads' do
      expect(GmailLabel).to receive(:update_num_unread_threads)
      gmail_account.emails_set_seen(Email.where(id: email), true)
    end
  end #__End of describe ".emails_set_seen"__

  describe ".trash_emails" do
    let(:email) { FactoryGirl.create(:email) }
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }

    before(:each) {
      $config.gmail_live = true
    }

    it 'executes the batch request by the google api client' do
      emails = [email]

      allow(gmail_account).to receive(:google_o_auth2_token) { google_o_auth2_token }

      gmail_account.trash_emails(emails)

      expect(gmail_account).to have_received(:google_o_auth2_token).twice
    end
  end #__End of describe ".trash_emails"__

  describe ".trash_email" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label) }
    let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder)  }

    it 'destroys all the folder mappings of the email' do
      email_folder_mappings = EmailFolderMapping.where(:email => email)
      gmail_client = gmail_account.gmail_client

      allow(EmailFolderMapping).to receive(:where) { email_folder_mappings }
      allow(email_folder_mappings).to receive(:destroy_all)

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:messages_trash)

      gmail_account.trash_email(email, batch_request: false, gmail_client: nil)

      expect(email_folder_mappings).to have_received(:destroy_all)
    end

    it 'applys the label to the email' do
      email_folder_mappings = EmailFolderMapping.where(:email => email)
      gmail_client = gmail_account.gmail_client

      allow(EmailFolderMapping).to receive(:where) { email_folder_mappings }
      allow(email_folder_mappings).to receive(:destroy_all)
      allow(gmail_account).to receive(:apply_label_to_email)

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:messages_trash)

      gmail_account.trash_email(email, batch_request: false, gmail_client: nil)

      expect(gmail_account).to have_received(:apply_label_to_email)
    end

    context "when the gmail does not live" do
      before(:each) {
        $config.gmail_live = false
      }

      it 'returns the nil' do

        expect( gmail_account.trash_email(email, batch_request: false, gmail_client: nil) ).to be(nil)
      end
    end

    context "when the gmail lives" do
      before(:each) {
        $config.gmail_live = true
      }

      context "when the batch_request is true" do
        it 'calls the messages_trash_call method of the gmail client' do
          gmail_client = gmail_account.gmail_client

          allow(gmail_account).to receive(:gmail_client) { gmail_client }
          allow(gmail_client).to receive(:messages_trash_call)

          gmail_account.trash_email(email, batch_request: true, gmail_client: nil)

          expect( gmail_client ).to have_received(:messages_trash_call)
        end
      end

      context "when the batch_request is false" do
        it 'calls the messages_trash method of the gmail client' do
          gmail_client = gmail_account.gmail_client

          allow(gmail_account).to receive(:gmail_client) { gmail_client }
          allow(gmail_client).to receive(:messages_trash)

          gmail_account.trash_email(email, batch_request: false, gmail_client: nil)

          expect( gmail_client ).to have_received(:messages_trash)
        end
      end
    end #__End of context "when the gmail lives"__
  end #__End of describe ".trash_email"__

  describe ".wake_up" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:email_ids) { [email.id]}

    it 'applys the label to the emails' do

      allow(gmail_account).to receive(:apply_label_to_emails)

      gmail_account.wake_up(email_ids)

      expect( gmail_account ).to have_received(:apply_label_to_emails)
    end
  end #__End of describe ".wake_up"__

  describe ".remove_emails_from_folder" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }
    let(:emails) { [email] }

    before(:each) {
      $config.gmail_live = true
    }

    context "when the folder_id is nil" do
      it 'returns false' do
        expect( gmail_account.remove_emails_from_folder(emails, folder_id: nil) ).to be(false)
      end
    end

    context "when the folder_id is not nil" do

      it 'executes the batch request by the google api client' do
        batch_request = Google::APIClient::BatchRequest.new()
        gmail_client = gmail_account.gmail_client

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(Google::APIClient::BatchRequest).to receive(:new) { batch_request }
        allow(gmail_account).to receive(:remove_email_from_folder) { true }
        allow(batch_request).to receive(:add)
        allow(gmail_account).to receive(:google_o_auth2_token) { google_o_auth2_token }
        allow(google_o_auth2_token).to receive(:api_client) { api_client }
        allow(api_client).to receive(:execute!)

        gmail_account.remove_emails_from_folder(emails, folder_id: 1)

        expect(gmail_account).to have_received(:google_o_auth2_token)
      end
    end
  end #__End of describe ".remove_emails_from_folder"__

  describe ".remove_email_from_folder" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label) }
    let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder)  }

    context "when the folder_id is nil" do
      it 'returns false' do
        expect( gmail_account.remove_email_from_folder(email, folder_id: nil, batch_request: false, gmail_client: nil) ).to be(false)
      end
    end

    context "when the folder_id is not nil" do
      it 'destroys all the folder mappings of the email' do
        email_folder_mappings = EmailFolderMapping.where(:email => email)
        gmail_client = gmail_account.gmail_client

        allow(GmailLabel).to receive(:find_by) { email_folder }
        allow(EmailFolderMapping).to receive(:where) { email_folder_mappings }
        allow(email_folder_mappings).to receive(:destroy_all)

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(gmail_client).to receive(:messages_modify)

        gmail_account.remove_email_from_folder(email, folder_id: 1, batch_request: false, gmail_client: nil)

        expect(email_folder_mappings).to have_received(:destroy_all)
      end

      context "when the gmail does not live" do
        before(:each) {
          $config.gmail_live = false
        }

        it 'returns the nil' do

          allow(GmailLabel).to receive(:find_by) { email_folder }

          expect( gmail_account.remove_email_from_folder(email, folder_id: 1, batch_request: false, gmail_client: nil) ).to be(nil)
        end
      end

      context "when the gmail lives" do
        before(:each) {
          $config.gmail_live = true
          allow(GmailLabel).to receive(:find_by) { email_folder }
        }

        context "when the batch_request is true" do
          it 'calls the messages_trash_call method of the gmail client' do
            gmail_client = gmail_account.gmail_client

            allow(gmail_account).to receive(:gmail_client) { gmail_client }
            allow(gmail_client).to receive(:messages_modify_call)

            gmail_account.remove_email_from_folder(email, folder_id: 1, batch_request: true, gmail_client: nil)

            expect( gmail_client ).to have_received(:messages_modify_call)
          end
        end

        context "when the batch_request is false" do
          it 'calls the messages_trash method of the gmail client' do
            gmail_client = gmail_account.gmail_client

            allow(gmail_account).to receive(:gmail_client) { gmail_client }
            allow(gmail_client).to receive(:messages_modify)

            gmail_account.remove_email_from_folder(email, folder_id: 1, batch_request: false, gmail_client: nil)

            expect( gmail_client ).to have_received(:messages_modify)
          end
        end
      end #__End of context "when the gmail lives"__
    end #__End of context "when the folder_id is not nil"__
  end #__End of describe ".remove_email_from_folder"__

  describe ".move_emails_to_folder" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }
    let(:emails) { Email.all }

    before(:each) {
      $config.gmail_live = true
    }

    context "when the folder_id and the folder_name is nil" do
      it 'returns false' do
        expect( gmail_account.move_emails_to_folder(emails, folder_id: nil, folder_name: nil, set_auto_filed_folder: false) ).to be(false)
      end
    end

    context "when the folder_id or the folder_name is not nil" do

      it 'executes the batch request by the google api client' do
        batch_request = Google::APIClient::BatchRequest.new()
        gmail_client = gmail_account.gmail_client

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(Google::APIClient::BatchRequest).to receive(:new) { batch_request }
        allow(gmail_account).to receive(:move_email_to_folder) { true }
        allow(batch_request).to receive(:add)
        allow(gmail_account).to receive(:google_o_auth2_token) { google_o_auth2_token }
        allow(google_o_auth2_token).to receive(:api_client) { api_client }
        allow(api_client).to receive(:execute!)

        gmail_account.move_emails_to_folder(emails, folder_id: 1, folder_name: nil, set_auto_filed_folder: false)

        expect(gmail_account).to have_received(:google_o_auth2_token)
      end
    end
  end #__End of describe ".move_emails_to_folder"__

  describe ".move_email_to_folder" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label) }
    let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder)  }

    context "when the folder_id and the folder_name is nil" do
      it 'returns false' do
        expect( gmail_account.move_email_to_folder(email, folder_id: nil, folder_name: nil, set_auto_filed_folder: false, batch_request: false, gmail_client: nil) ).to be(false)
      end
    end

    context "when the folder_id is not nil" do
      before(:each) {
        @gmail_client = gmail_account.gmail_client

        allow(EmailFolderMapping).to receive(:destroy_all)
        allow(gmail_account).to receive(:apply_label_to_email) { [email_folder, true] }
        allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      }

      it 'destroys all the folder mappings of the email' do

        allow(@gmail_client).to receive(:messages_modify)

        gmail_account.move_email_to_folder(email, folder_id: 1, folder_name: nil, set_auto_filed_folder: false, batch_request: false, gmail_client: nil)

        expect(EmailFolderMapping).to have_received(:destroy_all)
      end

      context "when the gmail lives" do
        before(:each) {
          $config.gmail_live = true
        }

        context "when the batch_request is true" do
          it 'calls the messages_modify_call method of the gmail client' do

            allow(@gmail_client).to receive(:messages_modify_call)

            gmail_account.move_email_to_folder(email, folder_id: 1, folder_name: nil, set_auto_filed_folder: false, batch_request: true, gmail_client: nil)

            expect( @gmail_client ).to have_received(:messages_modify_call)
          end
        end

        context "when the batch_request is false" do
          it 'calls the messages_modify method of the gmail client' do

            allow(@gmail_client).to receive(:messages_modify)

            gmail_account.move_email_to_folder(email, folder_id: 1, folder_name: nil, set_auto_filed_folder: false, batch_request: false, gmail_client: nil)

            expect( @gmail_client ).to have_received(:messages_modify)
          end
        end
      end #__End of context "when the gmail lives"__
    end #__End of context "when the folder_id is not nil"__
  end #__End of describe ".remove_email_from_folder"__

  describe ".apply_label_to_emails" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }
    let(:emails) { Email.all }

    before(:each) {
      $config.gmail_live = true
    }

    context "when the label_id and the label_name is nil" do
      it 'returns false' do
        expect( gmail_account.apply_label_to_emails(emails, label_id: nil, label_name: nil, set_auto_filed_folder: false) ).to be(false)
      end
    end

    context "when the folder_id or the folder_name is not nil" do
      before(:each) {
        @gmail_label = true

        batch_request = Google::APIClient::BatchRequest.new()
        gmail_client = gmail_account.gmail_client

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(Google::APIClient::BatchRequest).to receive(:new) { batch_request }
        allow(gmail_account).to receive(:apply_label_to_email) { @gmail_label }
        allow(batch_request).to receive(:add)

        allow(gmail_account).to receive(:google_o_auth2_token) { google_o_auth2_token }
        allow(google_o_auth2_token).to receive(:api_client) { api_client }
        allow(api_client).to receive(:execute!)
      }

      it 'executes the batch request by the google api client' do


        gmail_account.apply_label_to_emails(emails, label_id: 1, label_name: nil, set_auto_filed_folder: false)

        expect(gmail_account).to have_received(:google_o_auth2_token)
      end

      it 'returns the gmail label' do
        expect( gmail_account.apply_label_to_emails(emails, label_id: 1, label_name: nil, set_auto_filed_folder: false) ).to eq(@gmail_label)
      end
    end
  end #__End of describe ".apply_label_to_emails"__

  describe ".apply_label_to_email" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label) }
    let(:api_client) { Google::APIClient.new(
                                              :application_name => 'Example Ruby application',
                                              :application_version => '1.0.0'
                                            )
                      }
    let(:emails) { [email] }

    context "when the label_id and the label_name is nil" do
      it 'returns nil' do
        expect( gmail_account.apply_label_to_email(email, label_id: nil, label_name: nil, set_auto_filed_folder: false, batch_request: false, gmail_client: nil, gmail_sync: true) ).to be(nil)
      end
    end

    context "when no the label_id or the label_name is nil" do
      before(:each) {
        allow_any_instance_of(GmailAccount).to receive(:find_or_create_label).and_return(gmail_label)
        allow_any_instance_of(Google::GmailClient).to receive(:messages_modify)
      }

      context "when the label_id is not 'UNREAD'" do

        it 'creates new gmail label' do
          expect_any_instance_of(GmailAccount).to receive(:find_or_create_label).with(label_id: 1, label_name: nil).and_return(gmail_label)
          gmail_account.apply_label_to_email(email, label_id: 1)
        end

        it 'applys the email to the gmail label' do
          expect_any_instance_of(GmailLabel).to receive(:apply_to_emails)
          gmail_account.apply_label_to_email(email, label_id: 1)
        end

        it 'returns the gmail label' do
          expect( gmail_account.apply_label_to_email(email, label_id: 1) ).to eq( [gmail_label, nil])
        end

        context "when the set_auto_filed_folder is true" do

          it 'updates the auto_filed_folder field to the gmail label' do
            gmail_account.apply_label_to_email(email, label_id: 1, set_auto_filed_folder: true)

            email.reload

            expect( email.auto_filed_folder.id ).to eq( gmail_label.id )
          end
        end
      end #__End of context "when the label_id is not 'UNREAD'"__

      context "when the label_id is 'UNREAD'" do

        it 'returns nil' do
          expect( gmail_account.apply_label_to_email(email, label_id: 'UNREAD') ).to eq( [nil, nil])
        end

        context "when the set_auto_filed_folder is true" do

          it 'updates the auto_filed_folder field to nil' do
            gmail_account.apply_label_to_email(email, label_id: 'UNREAD', set_auto_filed_folder: true)

            email.reload

            expect( email.auto_filed_folder ).to eq( nil )
          end
        end
      end #__End of context "when the label_id is 'UNREAD'"__

      context "when the gmail is synchronized" do
        before do
          $config.gmail_live = true
        end

        context "when the batch_request is true" do
          it 'calls the messages_modify_call method of the gmail client' do
            expect_any_instance_of(Google::GmailClient).to receive(:messages_modify_call)
            gmail_account.apply_label_to_email(email, label_id: 'UNREAD', batch_request: true, gmail_sync: true)
          end
        end

        context "when the batch_request is not true" do
          it 'calls the messages_modify method of the gmail client' do
            expect_any_instance_of(Google::GmailClient).to receive(:messages_modify)
            gmail_account.apply_label_to_email(email, label_id: 'UNREAD', batch_request: false, gmail_sync: true)
          end
        end
      end #__End of context "when the gmail is synchronized"__
    end #__End of context "when the batch_request is true"__
  end #__End of describe ".apply_label_to_email"__

  describe ".search_threads" do
    let(:query) { "custom query" }
    let!(:threads_list_data) {
      {
        'threads' => [{'id'=>1}],
        'nextPageToken' => 'next page token'
      }
    }

    before(:each) {
      @gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:threads_list) { threads_list_data }
    }

    it 'returns the thread uids' do
      expected = threads_list_data['threads'].map{|v| v['id']}

      expect( gmail_account.search_threads(query).first ).to eq(expected)
    end

    it 'returns the next page token' do
      expected = threads_list_data['nextPageToken']

      expect( gmail_account.search_threads(query).last ).to eq(expected)
    end
  end #__End of describe ".search_threads"__

  describe ".process_sync_failed_emails" do
    let!(:sync_failed_email) { FactoryGirl.create(:sync_failed_email, email_account: gmail_account) }

    before(:each) {
      @sync_failed_emails = SyncFailedEmail.all

      allow(gmail_account).to receive(:sync_failed_emails) { @sync_failed_emails }
      allow(@sync_failed_emails).to receive(:where) { @sync_failed_emails }
      allow(@sync_failed_emails).to receive(:delete_all)

    }

    it 'deletes all the sync failed emails' do

      gmail_account.process_sync_failed_emails

      expect(@sync_failed_emails).to have_received(:delete_all)
    end

    context "when the delay is true" do

      it 'synchronizes the emails in the background' do
        expect( gmail_account.process_sync_failed_emails(delay: true).count ).not_to eq(0)
      end
    end

    context "when the delay is not true" do
      it 'synchronizes the emails directly' do
        allow(gmail_account).to receive(:sync_gmail_ids)

        gmail_account.process_sync_failed_emails(delay: false)

        expect(gmail_account).to have_received(:sync_gmail_ids)
      end

      it 'returns the empty array' do
        expect( gmail_account.process_sync_failed_emails(delay: false) ).to eq([])
      end
    end

    context "for no sync failed emails" do
      it 'returns the empty array' do
        allow(@sync_failed_emails).to receive(:pluck) { [] }

        expect( gmail_account.process_sync_failed_emails(delay: false) ).to eq([])
      end
    end
  end #__End of describe ".process_sync_failed_emails"__

  describe ".sync_reset" do
    it 'deletes all the email folder mappings' do
      folder_mappings = EmailFolderMapping.all
      allow(EmailFolderMapping).to receive(:where) { folder_mappings }
      allow(folder_mappings).to receive(:delete_all)

      gmail_account.sync_reset

      expect(folder_mappings).to have_received(:delete_all)
    end

    it 'deletes all the email recipients' do
      recipients = EmailRecipient.all
      allow(EmailRecipient).to receive(:where) { recipients }
      allow(recipients).to receive(:delete_all)

      gmail_account.sync_reset

      expect(recipients).to have_received(:delete_all).twice
    end

    it 'deletes all the email references' do
      references = EmailReference.all
      allow(EmailReference).to receive(:where) { references }
      allow(references).to receive(:delete_all)

      gmail_account.sync_reset

      expect(references).to have_received(:delete_all)
    end

    it 'deletes all the email in reply tos' do
      reply_tos = EmailInReplyTo.all
      allow(EmailInReplyTo).to receive(:where) { reply_tos }
      allow(reply_tos).to receive(:delete_all)

      gmail_account.sync_reset

      expect(reply_tos).to have_received(:delete_all)
    end

    it 'deletes all the email attachments' do
      attachments = EmailAttachment.all
      allow(EmailAttachment).to receive(:where) { attachments }
      allow(attachments).to receive(:delete_all)

      gmail_account.sync_reset

      expect(attachments).to have_received(:delete_all)
    end

    it 'deletes all the emails' do
      emails = Email.all

      allow(gmail_account).to receive(:emails) { emails }
      allow(emails).to receive(:delete_all)

      gmail_account.sync_reset

      expect(emails).to have_received(:delete_all)
    end

    it 'deletes all the email threads' do
      email_threads = EmailThread.all

      allow(gmail_account).to receive(:email_threads) { email_threads }
      allow(email_threads).to receive(:delete_all)

      gmail_account.sync_reset

      expect(email_threads).to have_received(:delete_all)
    end

    it 'deletes all the people' do
      people = Person.all

      allow(gmail_account).to receive(:people) { people }
      allow(people).to receive(:delete_all)

      gmail_account.sync_reset

      expect(people).to have_received(:delete_all)
    end

    it 'deletes all the synch failed emails' do
      sync_failed_emails = SyncFailedEmail.all

      allow(SyncFailedEmail).to receive(:where) { sync_failed_emails }
      allow(sync_failed_emails).to receive(:delete_all)

      gmail_account.sync_reset

      expect(sync_failed_emails).to have_received(:delete_all)
    end

    it 'deletes all the list subscriptions' do
      list_subscriptions = ListSubscription.all

      allow(ListSubscription).to receive(:where) { list_subscriptions }
      allow(list_subscriptions).to receive(:delete_all)

      gmail_account.sync_reset

      expect(list_subscriptions).to have_received(:delete_all)
    end

    it 'updates the sync_started_time to nil' do
      gmail_account.sync_reset

      expect(gmail_account.sync_started_time).to eq(nil)
    end

    context "when the reset_history_id is true" do
      it 'updates the last_history_id_synced to nil' do
        gmail_account.sync_reset(reset_history_id = true)

        expect(gmail_account.last_history_id_synced).to eq(nil)
      end
    end
  end #__End of describe ".sync_reset"__

  describe ".check_initial_sync" do
    let!(:job_ids) { [1] }
    let!(:another_gmail_account) { FactoryGirl.create(:gmail_account) }

    context "when the pending job does not exist" do
      before(:each) {
        allow(Delayed::Job).to receive(:where) { job_ids }
        allow(job_ids).to receive(:count) { 0 }
      }

      it 'runs brain and report' do
        allow(EmailGenie).to receive(:run_brain_and_report)

        gmail_account.check_initial_sync(job_ids)

        expect(EmailGenie).to have_received(:run_brain_and_report)
      end
    end

    context "when the pending jobs exist" do
      before(:each) {
        allow(Delayed::Job).to receive(:where) { job_ids }
        allow(job_ids).to receive(:count) { 1 }
      }

      it 'checks the initial sync' do

        allow(gmail_account).to receive(:delay) { another_gmail_account }
        allow(another_gmail_account).to receive(:check_initial_sync)

        gmail_account.check_initial_sync(job_ids)

        expect(another_gmail_account).to have_received(:check_initial_sync)
      end
    end
  end #__End of describe ".check_initial_sync"__

  describe ".queue_sync_account" do
    context "with #sync_lock false" do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, sync_lock: false) }

      it 'adds background job with lock' do
        expect(SyncAccountJob).to receive(:perform_later).once
        gmail_account.queue_sync_account
        gmail_account.reload

        expect(gmail_account.sync_lock).to be_truthy
      end
    end

    context "with #sync_lock true" do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, sync_lock: true) }

      it 'does nothing' do
        expect(SyncAccountJob).to_not receive(:perform_later)
        gmail_account.queue_sync_account
      end
    end
  end #__End of describe ".queue_sync_account"__

  describe ".sync_account" do
    before(:each) {
      allow(gmail_account).to receive(:sync_labels)
      allow(gmail_account).to receive(:sync_email)

      gmail_account.sync_account
    }

    it 'synchronizes the labels' do
      expect(gmail_account).to have_received(:sync_labels)
    end

    it 'synchronizes the email' do
      expect(gmail_account).to have_received(:sync_email)
    end
  end #__End of describe ".sync_account"__

  describe ".sync_email" do
    before do
      $stdout = StringIO.new
    end

    after(:all) do
      $stdout = STDOUT
    end

    context "when the sync is started more than 2 hours before" do
      before(:each) {
        gmail_account.sync_started_time = 3.hours.ago
        gmail_account.save
      }

      it 'prints the "DOING SYNC! with seconds_since_sync_started=~" on the console' do

        gmail_account.sync_email

        expect($stdout.string).to match(/DOING SYNC! with seconds_since_sync_started=/)
      end
    end

    context "when the sync is started less than 2 hours before" do

      before(:each) {
        gmail_account.sync_started_time = 1.hours.ago
        gmail_account.save
      }

      it 'prints the "SKIPPING SYNC because seconds_since_sync_started=~" on the console' do

        gmail_account.sync_email

        expect($stdout.string).to match(/SKIPPING SYNC because seconds_since_sync_started=/)

      end

      it 'returns the empty array' do
        expect( gmail_account.sync_email ).to eq( [] )
      end
    end

    context "when the last history id is not synced" do
      before(:each) {
        gmail_account.last_history_id_synced = nil
        gmail_account.save

        allow(gmail_account).to receive(:sync_draft_ids)

        gmail_account.sync_email
      }

      it 'prints the "INITIAL SYNC!!~" on the console' do
        expect($stdout.string).to match(/INITIAL SYNC!!/)
      end
    end

    context "when the user does not have genie report ran" do
      before(:each) {
        user = gmail_account.user
        user.has_genie_report_ran = false
        user.save

        allow(gmail_account).to receive(:sync_draft_ids)

        gmail_account.sync_email
      }

      it 'prints the "~queueing check_initial_sync with~" on the console' do
        expect($stdout.string).to match(/queueing check_initial_sync with/)
      end
    end

    context "when the last history id is synced and the user has genie report ran" do
      before(:each) {
        gmail_account.last_history_id_synced = "last history is synced"
        gmail_account.save
        user = gmail_account.user
        user.has_genie_report_ran = true
        user.save

        gmail_account.sync_email
      }

      it 'prints the "SUBSEQUENT SYNC!!~" on the console' do
        expect($stdout.string).to match(/SUBSEQUENT SYNC!!/)
      end
    end

    it 'returns the job ids' do
      job_ids = [1]

      allow(gmail_account).to receive(:sync_draft_ids)
      allow(gmail_account).to receive(:process_sync_failed_emails) { job_ids }

      expect( gmail_account.sync_email ).to eq( job_ids )
    end

    context "for the Google::APIClient::ClientError" do
      let!(:job_ids) { [1] }

      before(:each) {
        @ex = Google::APIClient::ClientError.new
        @ex_result = {}
        @ex_result_data = {}
        allow(gmail_account).to receive(:sync_draft_ids) {
          raise @ex
        }
        allow(@ex).to receive(:result) { @ex_result }
        allow(@ex_result).to receive(:data) { @ex_result_data }
        allow(gmail_account).to receive(:process_sync_failed_emails) { job_ids }
      }

      context "when the error reason is authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'authError'
                        ]
          }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'returns the job ids' do
          expect( gmail_account.sync_email ).to eq( job_ids )
        end
      end

      context "when the error reason is not authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'not authError'
                        ]
          }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'raises the Google::APIClient::ClientError' do
          expect {gmail_account.sync_email}.to raise_exception(Google::APIClient::ClientError)
        end
      end
    end

    context "for the Signet::AuthorizationError" do
      let!(:job_ids) { [1] }

      before(:each) {
        allow(gmail_account).to receive(:process_sync_failed_emails) { job_ids }
        allow(gmail_account).to receive(:sync_draft_ids) {
          raise Signet::AuthorizationError.new("message", {})
        }
      }

      it 'returns the empty array as the job ids' do
        expect( gmail_account.sync_email ).to eq( job_ids )
      end
    end
  end #__End of describe ".sync_email"__

  describe ".sync_labels" do
    it 'synchronizes the labels' do
      gmail_client = gmail_account.gmail_client
      label_data = "label data"

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:labels_list) { {'labels' => [label_data]} }
      allow(gmail_account).to receive(:sync_label_data)

      gmail_account.sync_labels

      expect(gmail_account).to have_received(:sync_label_data)
    end
  end #__End of describe ".sync_labels"__

  describe ".sync_label_data" do
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let(:label_data) {
      {
        'id' => 'label id',
        'name' => 'label name',
        'messageListVisibility' => 'message list visibility',
        'labelListVisibility' => 'label list visibility',
        'type' => 'label type'
      }
    }

    context "with the valid label id" do
      before(:each) {
        label_data['id'] = gmail_label.label_id
      }

      it 'returns the gmail label' do
        expect( gmail_account.sync_label_data(label_data).id ).to eq( gmail_label.id )
      end
    end

    context "with the valid label name" do
      before(:each) {
        label_data['name'] = gmail_label.name
      }

      it 'returns the gmail label' do
        expect( gmail_account.sync_label_data(label_data).id ).to eq( gmail_label.id )
      end
    end

    context "with the invalid label id and invalid label name" do
      it 'creates new gmail label' do
        expect{ gmail_account.sync_label_data(label_data) }.to change { GmailLabel.count }.by(1)
      end
    end

    it 'updates the label_id to the id of the label data' do
      expect( gmail_account.sync_label_data(label_data).label_id ).to eq( label_data['id'] )
    end

    it 'updates the name to the name of the label data' do
      expect( gmail_account.sync_label_data(label_data).name ).to eq( label_data['name'] )
    end

    it 'updates the message_list_visibility to the messageListVisibility of the label data' do
      expect( gmail_account.sync_label_data(label_data).message_list_visibility ).to eq( label_data['messageListVisibility'] )
    end

    it 'updates the label_list_visibility to the labelListVisibility of the label data' do
      expect( gmail_account.sync_label_data(label_data).label_list_visibility ).to eq( label_data['labelListVisibility'] )
    end

    it 'updates the label_type to the type of the label data' do
      expect( gmail_account.sync_label_data(label_data).label_type ).to eq( label_data['type'] )
    end

    context "when the ActiveRecord::RecordNotUnique raises" do
      before(:each) {
        gmail_label2 = FactoryGirl.create(:gmail_label, gmail_account: gmail_account)
        gmail_label2.id = gmail_label.id

        allow(GmailLabel).to receive(:new) { gmail_label2 }
      }

      it 'raises the error' do
        expect { gmail_account.sync_label_data(label_data) }.to raise_error
      end
    end
  end #__End of describe ".sync_label_data"__

  describe ".sync_email_labels" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let(:label_data) {
      {
        'id' => 'label id',
        'name' => 'label name',
        'messageListVisibility' => 'message list visibility',
        'labelListVisibility' => 'label list visibility',
        'type' => 'label type'
      }
    }

    it 'destroys all the email folder mappings' do
      email_folder_mappings = EmailFolderMapping.all

      allow(email).to receive(:email_folder_mappings) { email_folder_mappings }
      allow(email_folder_mappings).to receive(:destroy_all)

      gmail_account.sync_email_labels(email, nil)

      expect(email_folder_mappings).to have_received(:destroy_all)
    end

    context "when the gmail_label_ids is not given" do
      it 'updates the seen field to the true' do
        gmail_account.sync_email_labels(email, nil)

        expect(email.seen).to be(true)
      end
    end

    context "when the gmail_label_ids is given" do
      let(:gmail_label_ids) { ['UNREAD', 'READ'] }

      it 'applys the label to the email' do
        gmail_client = gmail_account.gmail_client

        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(gmail_client).to receive(:labels_get) { label_data }
        allow(gmail_account).to receive(:sync_label_data) { gmail_label }
        allow(gmail_account).to receive(:apply_label_to_email)

        gmail_account.sync_email_labels(email, gmail_label_ids)

        expect(gmail_account).to have_received(:apply_label_to_email)
      end
    end
  end #__End of describe ".sync_email_labels"__

  describe ".sync_email_full" do
    let!(:messages_list_data) {
      {
        'messages' => [ {'id' => 'message-id'}]
      }
    }
    let!(:gmail_data) {
      {
        'historyId' => 'history-id'
      }
    }

    before(:each) {
      @gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:messages_list) { messages_list_data }
      allow(@gmail_client).to receive(:messages_get) { gmail_data }
    }

    it 'returns the job ids' do
      expect( gmail_account.sync_email_full.count ).not_to eq(0)
    end

    context "when the delay is false" do
      it 'synchronizes the gmail ids directly' do
        allow(gmail_account).to receive(:sync_gmail_ids)

        gmail_account.sync_email_full(delay: false)

        expect(gmail_account).to have_received(:sync_gmail_ids)
      end
    end

    context "when the Google::APIClient::ClientError raises" do
      it 'handles the google client error' do
        allow(gmail_account).to receive(:gmail_client) {
          raise Google::APIClient::ClientError
        }

        expect{ gmail_account.sync_email_full }.to raise_error

      end
    end

    context "for the heroku scale dynos" do
      context "for the Google::APIClient::ClientError" do
        before(:each) {
          @ex = Google::APIClient::ClientError.new
          @ex_result = {}
          @ex_result_data = {}
          allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
            raise @ex
          }
          allow(@ex).to receive(:result) { @ex_result }
          allow(@ex_result).to receive(:data) { @ex_result_data }
        }

        context "when the error reason is authError" do
          before(:each) {
            ex_result_data_error = {
              'errors' => [
                            'reason' => 'authError'
                          ]
            }
            allow(@ex_result_data).to receive(:error) { ex_result_data_error }
          }

          it 'returns the empty array as the job ids' do
            expect( gmail_account.sync_email_full ).to eq( [] )
          end
        end

        context "when the error reason is not authError" do
          before(:each) {
            ex_result_data_error = {
              'errors' => [
                            'reason' => 'not authError'
                          ]
            }
            allow(@ex_result_data).to receive(:error) { ex_result_data_error }
          }

          it 'raises the Google::APIClient::ClientError' do
            expect {gmail_account.sync_email_full}.to raise_exception(Google::APIClient::ClientError)
          end
        end
      end

      context "for the Exception" do
        before(:each) {
          allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
            raise Exception
          }
        }

        it 'raises the Exception' do
          expect {gmail_account.sync_email_full}.to raise_exception(Exception)
        end
      end

      context "for the Signet::AuthorizationError" do
        before(:each) {
          allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
            raise Signet::AuthorizationError.new("message", {})
          }
        }

        it 'returns the empty array as the job ids' do
          expect( gmail_account.sync_email_full ).to eq( [] )
        end
      end
    end
  end #__End of describe ".sync_email_full"__

  describe ".sync_email_partial" do
    context "for the heroku scale dynos" do
      context "for the Exception" do
        before(:each) {
          allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
            raise Exception
          }
        }

        it 'raises the Exception' do
          expect {gmail_account.sync_email_partial}.to raise_exception(Exception)
        end
      end
    end
    let!(:history_list_data) {
      {
        'history' => [
                      {'messages' => [
                                      {'id' => 'message-id'}
                                     ]
                      }
                     ]
      }
    }
    let!(:gmail_data) {
      {
        'historyId' => 'history-id'
      }
    }

    before(:each) {
      @gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:history_list) { history_list_data }
    }

    it 'returns the job ids' do
      expect( gmail_account.sync_email_partial.count ).not_to eq(0)
    end

    context "when the delay is false" do
      it 'synchronizes the gmail ids directly' do
        allow(gmail_account).to receive(:sync_gmail_ids)

        gmail_account.sync_email_partial(delay: false)

        expect(gmail_account).to have_received(:sync_gmail_ids)
      end
    end

    context "for the Google::APIClient::ClientError" do
      before(:each) {
        @ex = Google::APIClient::ClientError.new
        @ex_result = {}
        @ex_result_status = 404
        @ex_result_data = {}
        allow(gmail_account).to receive(:gmail_client) {
          raise @ex
        }

        allow(@ex).to receive(:result) { @ex_result }
      }

      context "when the error status is 404" do
        let(:full_sync_job_ids) { [111]}

        before(:each) {
          allow(@ex_result).to receive(:status) { @ex_result_status }
          allow(gmail_account).to receive(:sync_email_full) { full_sync_job_ids }
        }

        it 'returns the full synchronized job ids' do
          expect( gmail_account.sync_email_partial ).to eq( full_sync_job_ids )
        end
      end

      context "when the error reason is authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'authError'
                        ]
          }
          allow(@ex_result).to receive(:status) { 400 }
          allow(@ex_result).to receive(:data) { @ex_result_data }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'returns the empty array as the job ids' do
          expect( gmail_account.sync_email_partial ).to eq( [] )
        end
      end

      context "when the error reason is not authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'not authError'
                        ]
          }
          allow(@ex_result).to receive(:status) { 400 }
          allow(@ex_result).to receive(:data) { @ex_result_data }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'raises the Google::APIClient::ClientError' do
          expect {gmail_account.sync_email_partial}.to raise_exception(Google::APIClient::ClientError)
        end
      end
    end #__End of context "for the Google::APIClient::ClientError"__

    context "for the Signet::AuthorizationError" do
      before(:each) {
        allow(gmail_account).to receive(:gmail_client) {
          raise Signet::AuthorizationError.new("message", {})
        }
      }

      it 'returns the empty array as the job ids' do
        expect( gmail_account.sync_email_partial ).to eq( [] )
      end
    end
  end #__End of describe ".sync_email_partial"__

  describe ".create_email_from_gmail_data" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
    before(:each) {
      gmail_data['id'] = "email-uid"
      allow(Email).to receive(:email_from_email_raw) { email }
      allow(EmailThread).to receive(:find_or_create_by!) { email_thread }
    }

    it 'updates the email_thread of the email' do
      gmail_account.create_email_from_gmail_data(gmail_data)
      expect( email.email_thread ).to eq( email_thread )
    end

    it 'adds the references to the email' do
      allow(email).to receive(:add_references)

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect(email).to have_received(:add_references)
    end

    it 'adds the in_reply_tos to the email' do
      allow(email).to receive(:add_in_reply_tos)

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect(email).to have_received(:add_in_reply_tos)
    end

    it 'adds the recipients to the email' do
      allow(email).to receive(:add_recipients)

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect(email).to have_received(:add_recipients)
    end

    it 'adds the attachments to the email' do
      allow(email).to receive(:add_attachments)

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect(email).to have_received(:add_attachments)
    end

    it 'creates new list subscription' do
      list_subscription = FactoryGirl.create(:list_subscription, :email_account => gmail_account)

      allow(ListSubscription).to receive(:create_from_email_raw) { list_subscription }

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect( email.list_subscription ).to eq( list_subscription )
    end

    it 'synchronizes the email labels' do
      allow(gmail_account).to receive(:sync_email_labels)

      gmail_account.create_email_from_gmail_data(gmail_data)

      expect(gmail_account).to have_received(:sync_email_labels)
    end

    context "when the labelIds includes 'INBOX'" do
      before(:each) {
        gmail_data['labelIds'] = ['INBOX']
      }

      it 'applys the email labels to the email' do
        user = gmail_account.user
        allow(gmail_account).to receive(:sync_email_labels)
        allow(gmail_account).to receive(:user) { user }
        allow(user).to receive(:apply_email_rules_to_email)

        gmail_account.create_email_from_gmail_data(gmail_data)

        expect(user).to have_received(:apply_email_rules_to_email)
      end
    end

    context "when the list subscription of the email exists" do
      let!(:list_subscription) { FactoryGirl.create(:list_subscription, :email_account => gmail_account) }

      before(:each) {
        gmail_data['labelIds'] = []
        allow(email).to receive(:list_subscription) { list_subscription }
      }

      context "when the list subscription belongs to the subscriptions of the gmail account" do
        before(:each) {
          list_subscriptions = ListSubscription.all
          allow(gmail_account).to receive(:list_subscriptions) { list_subscriptions }
          allow(list_subscriptions).to receive(:where) { list_subscriptions }
        }

        it 'trashes the email' do
          allow(gmail_account).to receive(:trash_email)

          gmail_account.create_email_from_gmail_data(gmail_data)

          expect(gmail_account).to have_received(:trash_email)
        end
      end
    end

    context "when new email thread is created" do
      context "for the ActiveRecord::RecordNotUnique" do
        before(:each) {
          @ex = ActiveRecord::RecordNotUnique.new("message")
          allow(EmailThread).to receive(:find_or_create_by!) {
            raise @ex
          }
        }

        context "when the violation is not based on the email id and email type" do
          before(:each) {
            @ex_message = "error message"
            allow(@ex).to receive(:message) { @ex_message }
          }

          it 'retrys to create the email' do
            allow(SyncFailedEmail).to receive(:create_retry)

            gmail_account.create_email_from_gmail_data(gmail_data)

            expect(SyncFailedEmail).to have_received(:create_retry)
          end
        end

        context "when the violation is based on the email id and email type" do
          before(:each) {
            @ex_message = "index_emails_on_email_account_type_and_email_account_id_and_uid"
            allow(@ex).to receive(:message) { @ex_message }
          }

          context "when couldn't find the email by id of the gmail data" do
            before(:each) {
              allow(Email).to receive(:find_by_uid) { nil }
            }

            it 'retrys to create the email' do
              allow(SyncFailedEmail).to receive(:create_retry)

              gmail_account.create_email_from_gmail_data(gmail_data)

              expect(SyncFailedEmail).to have_received(:create_retry)
            end
          end

          context "when could find the email by id of the gmail data" do
            before(:each) {
              allow(Email).to receive(:find_by_uid) { email }
            }

            it 'synchronizes the email labels' do
              allow(gmail_account).to receive(:sync_email_labels)

              gmail_account.create_email_from_gmail_data(gmail_data)

              expect(gmail_account).to have_received(:sync_email_labels)
            end
          end

          it 'retrys to create the email' do
            gmail_account.create_email_from_gmail_data(gmail_data)
          end
        end
      end
    end

    context "for the SignalException" do
      before(:each) {
        allow(GmailAccount).to receive(:email_raw_from_gmail_data) {
          Process.kill('HUP',Process.pid)
        }
      }

      it 'raises the SignalException' do

        expect {gmail_account.create_email_from_gmail_data(gmail_data)}.to raise_exception(SignalException)
      end
    end

    context "for the Exception" do
      before(:each) {
        allow(GmailAccount).to receive(:email_raw_from_gmail_data) {
          raise Exception
        }
      }

      it 'retrys to create the email' do
        allow(SyncFailedEmail).to receive(:create_retry)

        gmail_account.create_email_from_gmail_data(gmail_data)

        expect(SyncFailedEmail).to have_received(:create_retry)
      end
    end
  end #__End of describe ".create_email_from_gmail_data"__

  describe ".update_email_from_gmail_data" do
    context "when couldn't find the email by the id of the gmail data" do
      it 'returns the nil' do
        allow(SyncFailedEmail).to receive(:create_retry)

        expect( gmail_account.update_email_from_gmail_data(gmail_data) ).to be(nil)
      end
    end

    context "when could find the email by the id of the gmail data" do
      before {
        email = FactoryGirl.create(:email)
        allow(Email).to receive(:find_by_uid) { email }
      }

      it 'synchronizes the email labels' do
        allow(gmail_account).to receive(:sync_email_labels)

        gmail_account.update_email_from_gmail_data(gmail_data)

        expect(gmail_account).to have_received(:sync_email_labels)
      end
    end
  end #__End of describe ".update_email_from_gmail_data"__

  describe ".sync_gmail_ids_batch_request" do
    context "when the batch request is failed" do
      context "when the response status is 404" do
        before do
          allow_any_instance_of(Google::APIClient::BatchedCallResponse).to receive(:status).and_return(404)
        end

        it 'destroys all the emails' do
          expect(Email).to receive(:destroy_all)

          batch_request = gmail_account.sync_gmail_ids_batch_request()
          call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
          batch_request.add(call)

          gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
        end
      end #__End of context "when the response status is 404"__

      context "when the response status is not 404" do
        it 'retrys the failed sync' do
          expect(SyncFailedEmail).to receive(:create_retry)

          batch_request = gmail_account.sync_gmail_ids_batch_request()
          call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
          batch_request.add(call)

          gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
        end
      end #__End of context "when the response status is not 404"__
    end #__End of context "when the batch request is failed"__

    context "when the batch request is successed" do
      before do
        allow_any_instance_of(Google::APIClient::Result).to receive(:error?).and_return(false)
      end

      context "for the delay" do
        let!(:batch_request) { gmail_account.sync_gmail_ids_batch_request(delay: true) }

        context "when the raw part of the gmail data exists" do
          let!(:gmail_data) {
            {
              'raw' => 'raw gmail data'
            }
          }

          it 'creates new email from the gmail data on the background' do
            call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
            batch_request.add(call)

            allow_any_instance_of(Google::APIClient::Result).to receive(:data).and_return(gmail_data)

            gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
          end
        end #__End of context "when the raw part of the gmail data exists"__

        context "when the raw part of the gmail data does not exist" do

          it 'updates the email with the gmail data on the background' do
            call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
            batch_request.add(call)

            gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
          end
        end #__End of context "when the raw part of the gmail data does not exist"__
      end #__End of context "for the delay"__

      context "for not delay" do
        let!(:batch_request) { gmail_account.sync_gmail_ids_batch_request(delay: false) }

        context "when the raw part of the gmail data exists" do
          let!(:gmail_data) {
            {
              'raw' => 'raw gmail data'
            }
          }

          it 'creates new email from the gmail data' do
            call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
            batch_request.add(call)

            allow_any_instance_of(Google::APIClient::Result).to receive(:data).and_return(gmail_data)

            expect(gmail_account).to receive(:create_email_from_gmail_data)
            gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
          end
        end #__End of context "when the raw part of the gmail data exists"__

        context "when the raw part of the gmail data does not exist" do

          it 'updates the email with the gmail data' do
            call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
            batch_request.add(call)

            expect(gmail_account).to receive(:update_email_from_gmail_data)

            gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
          end
        end #__End of context "when the raw part of the gmail data does not exist"__
      end #__End of context "for not delay"__

      context "for the Exception" do
        let!(:batch_request) { gmail_account.sync_gmail_ids_batch_request() }

        before do
          allow(gmail_account).to receive(:update_email_from_gmail_data) {
            raise Exception
          }
        end

        it 'retrys the failed email sync' do
          call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
          batch_request.add(call)

          expect(SyncFailedEmail).to receive(:create_retry)

          gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
        end
      end #__End of context "for the Exception"__

      context "for the SignalException" do
        let!(:batch_request) { gmail_account.sync_gmail_ids_batch_request() }

        before do
          allow(gmail_account).to receive(:update_email_from_gmail_data) {
            Process.kill('HUP',Process.pid)
          }
        end

        it 'retrys the failed email sync' do
          call = gmail_account.gmail_client.threads_get_call('me', 'thread_uid', format: 'metadata', metadataHeaders: 'subject')
          batch_request.add(call)

          expect { gmail_account.google_o_auth2_token.api_client.execute!(batch_request) }.to raise_exception(SignalException)
        end
      end #__End of context "for the SignalException"__
    end #__End of context "when the batch request is successed"__
  end #__End of describe ".sync_gmail_ids_batch_request"__

  describe ".sync_gmail_id" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:gmail_id) { email.uid }

    context "when the raw field of the gmail data exists" do
      before(:each) {
        gmail_client = gmail_account.gmail_client
        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(gmail_client).to receive(:messages_get) { {'raw' => 'raw gmail data'} }
      }

      it 'creates the email from the gmail data' do
        allow(gmail_account).to receive(:create_email_from_gmail_data)

        gmail_account.sync_gmail_id(gmail_id)

        expect(gmail_account).to have_received(:create_email_from_gmail_data)
      end
    end

    context "when the raw field of the gmail data does not exist" do
      before(:each) {
        gmail_client = gmail_account.gmail_client
        allow(gmail_account).to receive(:gmail_client) { gmail_client }
        allow(gmail_client).to receive(:messages_get) { {'raw' => nil} }
      }

      it 'updates the email from the gmail data' do
        allow(gmail_account).to receive(:update_email_from_gmail_data)

        gmail_account.sync_gmail_id(gmail_id)

        expect(gmail_account).to have_received(:update_email_from_gmail_data)
      end
    end

    context "for the SignalException" do
      before(:each) {
        allow(Email).to receive(:find_by_uid) {
          Process.kill('HUP',Process.pid)
        }
      }

      it 'raises the SignalException' do

        expect { gmail_account.sync_gmail_id(gmail_id) }.to raise_exception(SignalException)
      end
    end

    context "for the Exception" do
      before(:each) {
        @ex = Exception.new
        @ex_result = {}
        @ex_result_status = 404
        @ex_result_data = {}
        @ex_result_request = {}
        @ex_result_request_parameters = {'id' => "request-id"}
        allow(gmail_account).to receive(:gmail_client) {
          raise @ex
        }

        allow(@ex).to receive(:result) { @ex_result }
      }

      context "when the error status is 404" do
        before(:each) {
          allow(@ex_result).to receive(:status) { @ex_result_status }
          allow(@ex_result).to receive(:request) { @ex_result_request }
          allow(@ex_result_request).to receive(:parameters) { @ex_result_request_parameters }
        }

        it 'destroys all the emails' do
          allow(Email).to receive(:destroy_all)

          gmail_account.sync_gmail_id(gmail_id)

          expect(Email).to have_received(:destroy_all)
        end
      end

      context "when the error status is not 404" do
        before(:each) {
          allow(@ex_result).to receive(:status) { 400 }
        }

        it 'retrys to create the email' do
          allow(SyncFailedEmail).to receive(:create_retry)

          gmail_account.sync_gmail_id(gmail_id)

          expect(SyncFailedEmail).to have_received(:create_retry)
        end
      end
    end

  end #__End of describe ".sync_gmail_id"__

  describe ".sync_gmail_ids" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:gmail_ids_orig) { [email.uid] }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }

    context "when delay is true" do
      before(:each) {
        allow(HerokuTools::HerokuTools).to receive(:scale_dynos)
      }

      it "does heroku scale dynos" do
        gmail_account.sync_gmail_ids(gmail_ids_orig, delay: true)
        expect(HerokuTools::HerokuTools).to have_received(:scale_dynos)
      end

      it 'creates the background job to synchronize the gmail' do
        job = gmail_account.delay(heroku_scale: false).sync_gmail_id(gmail_ids_orig.first)

        allow(gmail_account).to receive(:delay) { gmail_account }
        allow(gmail_account).to receive(:sync_gmail_id) { job }

        gmail_account.sync_gmail_ids(gmail_ids_orig, delay: true)

        expect(gmail_account).to have_received(:sync_gmail_id)
      end
    end

    context "when the gmail_ids_orig is empty" do
      it 'returns the empty array' do
        expect( gmail_account.sync_gmail_ids([]) ).to eq( [] )
      end
    end

    context "for the ensure" do
      it 'updates the skip_update_counts of the GmailLabel to false' do
        gmail_account.sync_gmail_ids(gmail_ids_orig)
        expect( GmailLabel.skip_update_counts ).to be(false)
      end

      it 'udpates the counts of the gmail labels' do
        gmail_labels = GmailLabel.all

        allow(gmail_account).to receive(:gmail_labels) { gmail_labels }
        allow(GmailLabel).to receive(:update_counts)
        allow(gmail_labels).to receive(:each) { gmail_label }

        gmail_account.sync_gmail_ids(gmail_ids_orig)

        expect(GmailLabel).to have_received(:update_counts)
      end
    end

    context "for the Signet::AuthorizationError" do
      before(:each) {
        allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
          raise Signet::AuthorizationError.new("message", {})
        }
      }

      it 'returns the empty array as the job ids' do
        expect( gmail_account.sync_gmail_ids(gmail_ids_orig, delay: true) ).to eq( [] )
      end
    end

    context "for the Google::APIClient::ClientError" do
      before(:each) {
        @ex = Google::APIClient::ClientError.new
        @ex_result = {}
        @ex_result_data = {}
        allow(HerokuTools::HerokuTools).to receive(:scale_dynos) {
          raise @ex
        }

        allow(@ex).to receive(:result) { @ex_result }
      }

      context "when the error reason is authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'authError'
                        ]
          }
          allow(@ex_result).to receive(:data) { @ex_result_data }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'returns the empty array as the job ids' do
          expect( gmail_account.sync_gmail_ids(gmail_ids_orig, delay: true) ).to eq( [] )
        end
      end

      context "when the error reason is not authError" do
        before(:each) {
          ex_result_data_error = {
            'errors' => [
                          'reason' => 'not authError'
                        ]
          }
          allow(@ex_result).to receive(:data) { @ex_result_data }
          allow(@ex_result_data).to receive(:error) { ex_result_data_error }
        }

        it 'raises the Google::APIClient::ClientError' do
          expect {gmail_account.sync_gmail_ids(gmail_ids_orig, delay: true)}.to raise_exception(Google::APIClient::ClientError)
        end
      end
    end #__End of context "for the Google::APIClient::ClientError"__
  end #__End of describe ".sync_gmail_ids"__

  describe ".sync_gmail_thread" do
    let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
    let(:thread_data) {
      {'messages' => [{'id' => 'thread-id'}]}
    }

    it 'synchronizes the gmails' do
      gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:threads_get) { thread_data }
      allow(gmail_account).to receive(:sync_gmail_ids)

      gmail_account.sync_gmail_thread(email_thread.id)

      expect(gmail_account).to have_received(:sync_gmail_ids)
    end
  end #__End of describe ".sync_gmail_thread"__

  describe ".send_email_raw" do
    let(:email_raw) { "raw email" }
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, email: email) }

    before(:each) {
      @gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:messages_send) { gmail_data }
      allow(gmail_account).to receive(:sync_gmail_ids)
    }

    context "when the email_in_reply_to is given" do
      it 'sends the email by the email_in_reply_to' do
        gmail_account.send_email_raw(email_raw, email_in_reply_to)
        expect(@gmail_client).to have_received(:messages_send)
      end
    end

    context "when the email_in_reply_to is false" do
      it 'sends the email by the email_raw' do
        gmail_account.send_email_raw(email_raw, nil)
        expect(@gmail_client).to have_received(:messages_send)
      end
    end

    it 'synchronizes the gmail ids' do
      gmail_account.send_email_raw(email_raw, nil)
      expect(gmail_account).to have_received(:sync_gmail_ids)
    end

    it 'returns the email' do
      emails = Email.all

      allow(gmail_account).to receive(:emails) { emails }
      allow(emails).to receive(:find_by) { email }

      expect( gmail_account.send_email_raw(email_raw, nil) ).to eq( email )
    end
  end #__End of describe ".send_email_raw"__

  describe ".send_email" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, email: email) }
    let!(:email_raw) {
      Mail.new
    }

    before(:each) {
      @tos = nil
      @ccs = nil
      @bccs = nil
      @subject = nil
      @html_part = nil
      @text_part = nil
      @email_in_reply_to_uid = nil
      @tracking_enabled = false
      @bounce_back = false
      @bounce_back_time = nil
      @bounce_back_type = nil
      @attachment_s3_keys = []

      allow(Email).to receive(:email_raw_from_params) { [email_raw, email_in_reply_to] }
      allow(email_raw).to receive(:deliver!)
      allow(gmail_account).to receive(:sync_email)
    }

    it 'delivers the email' do
      gmail_account.send_email
      expect(email_raw).to have_received(:deliver!)
    end

    it 'synchronizes the email' do
      gmail_account.send_email
      expect(gmail_account).to have_received(:sync_email)
    end

    context "when the tracking_enabled is true" do
      before(:each) {
        @tracking_enabled = true
        @subject = "email subject"
      }

      it 'creates new email tracker' do
        expect{ gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys) }.to change { EmailTracker.count }.by(1)
      end

      context "when the tos is given" do
        before(:each) {
          @tos = ["to@email.com"]
        }

        it 'creates new email tracker recipient' do
          expect{ gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys) }.to change { EmailTrackerRecipient.count }.by(1)
        end

        context "when the to address is blank" do
          it 'does nothing' do
            @tos = [""]

            gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

            expect(EmailTrackerRecipient.count).to eq(0)
          end
        end

        it 'saves the email_address to the of the email tracker recipient to the to address' do
          gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

          email_tracker_recipient = EmailTrackerRecipient.first

          expect(email_tracker_recipient.email_address).to eq(@tos.first)
        end
      end

      context "when the ccs is given" do
        before(:each) {
          @ccs = ["cc@email.com"]
        }

        it 'creates new email tracker recipient' do
          expect{ gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys) }.to change { EmailTrackerRecipient.count }.by(1)
        end

        context "when the cc address is blank" do
          it 'does nothing' do
            @ccs = [""]

            gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

            expect(EmailTrackerRecipient.count).to eq(0)
          end
        end

        it 'saves the email_address to the of the email tracker recipient to the cc address' do
          gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

          email_tracker_recipient = EmailTrackerRecipient.first

          expect(email_tracker_recipient.email_address).to eq(@ccs.first)
        end
      end

      context "when the bccs is given" do
        before(:each) {
          @bccs = ["bcc@email.com"]
        }

        it 'creates new email tracker recipient' do
          expect{ gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys) }.to change { EmailTrackerRecipient.count }.by(1)
        end

        context "when the bcc address is blank" do
          it 'does nothing' do
            @bccs = [""]

            gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

            expect(EmailTrackerRecipient.count).to eq(0)
          end
        end

        it 'saves the email_address to the of the email tracker recipient to the bcc address' do
          gmail_account.send_email(@tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

          email_tracker_recipient = EmailTrackerRecipient.first

          expect(email_tracker_recipient.email_address).to eq(@bccs.first)
        end
      end

    end

    context "when the email is found by the message id of the raw email" do
      before(:each) {
        emails = Email.all
        allow(gmail_account).to receive(:emails) { emails }
        allow(emails).to receive(:find_by_message_id) { email }
      }

      context "when the bounce_back is given" do
        before(:each) {
          @bounce_back = true
          @bounce_back_time = Time.now
          @bounce_back_type = "always"
          @job = email.delay({:run_at => @bounce_back_time}, heroku_scale: false).run_bounce_back()
          allow(email).to receive(:delay) { email }
          allow(email).to receive(:run_bounce_back) { @job }

          gmail_account.send_email( @tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)
        }
        it 'updates the bounce_back to the true' do
          expect(email.bounce_back).to be(true)
        end

        it 'updates the bounce_back_time to the bounce_back_time' do
          expect(email.bounce_back_time).to eq(@bounce_back_time)
        end

        it 'updates the bounce_back_type to the bounce_back_type' do
          expect(email.bounce_back_type).to eq(@bounce_back_type)
        end

        it 'creates the background job to run the bounch back' do
          expect(email).to have_received(:run_bounce_back)
        end

        it 'updates the bounce_back_job_id to the background job id' do
          expect(email.bounce_back_job_id).to eq(@job.id)
        end
      end

      context "when attachment_s3_keys are given" do
        before(:each) {
          @attachment_s3_keys = ["s3-key"]
        }

        it 'destroys the email attachments' do
          user = email.user
          email_attachment_upload = FactoryGirl.create(:email_attachment_upload, user: user)
          email_attachment_uploads = EmailAttachmentUpload.all

          allow(email).to receive(:user) { user }
          allow(user).to receive(:email_attachment_uploads) { email_attachment_uploads }
          allow(email_attachment_uploads).to receive(:find_by_s3_key) { email_attachment_upload }
          allow(email_attachment_upload).to receive(:destroy!)

          gmail_account.send_email( @tos, @ccs, @bccs, @subject, @html_part, @text_part, @email_in_reply_to_uid, @tracking_enabled, @bounce_back, @bounce_back_time, @bounce_back_type, @attachment_s3_keys)

          expect(email_attachment_upload).to have_received(:destroy!)
        end
      end
    end #__End of context "when the email is found by the message id of the raw email"__
  end #__End of describe ".send_email"__

  describe ".get_draft_ids" do
    let!(:drafts_list_data) {
      {'drafts' => [
                    {
                      'id' => 'draft-id',
                      'message' => {'id' => 'message-id'}
                    }
                  ]
      }
    }

    before(:each) {
      gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { gmail_client }
      allow(gmail_client).to receive(:drafts_list) { drafts_list_data }
    }

    it 'returns the draft ids' do
      key = drafts_list_data['drafts'].first['message']['id']
      value = drafts_list_data['drafts'].first['id']

      expected = { key => value }
      expect( gmail_account.get_draft_ids ).to eq( expected )
    end
  end #__End of describe ".get_draft_ids"__

  describe ".sync_draft_ids" do
    let!(:gmail_id) { 'gmail-id' }
    let!(:draft_id) { 'draft-id' }
    let!(:draft_ids) { [[gmail_id, draft_id]] }

    before(:each) {
      @emails = Email.all

      allow(gmail_account).to receive(:get_draft_ids) { draft_ids }
      allow(gmail_account).to receive(:emails) { @emails }
      allow(@emails).to receive(:where) { @emails }
      allow(@emails).to receive(:update_all)
    }

    it 'synchronizes all the draft ids' do
      gmail_account.sync_draft_ids

      expect(@emails).to have_received(:update_all)
    end
  end #__End of describe ".sync_draft_ids"__

  describe ".sync_draft_data" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:attachment_s3_keys) { ['/aws/s3-key'] }
    let!(:draft_data) {
      {
        'id' => 'draft-id',
        'message' => {'id' => 'message-id'}
      }
    }

    before(:each) {
      @emails = Email.all
      @user = gmail_account.user

      allow(gmail_account).to receive(:emails) { @emails }
      allow(@emails).to receive(:where) { @emails }
      allow(@emails).to receive(:destroy_all)

      allow(gmail_account).to receive(:sync_gmail_ids)

      allow(@emails).to receive(:find_by) { email }



      @email_attachment_upload = FactoryGirl.create(:email_attachment_upload, user: @user)
      @email_attachment_uploads = EmailAttachmentUpload.all

      allow(gmail_account).to receive(:user) { @user }
      allow(@user).to receive(:email_attachment_uploads) { @email_attachment_uploads }
      allow(@email_attachment_uploads).to receive(:find_by_s3_key) { @email_attachment_upload }

      gmail_account.sync_draft_data(draft_data, attachment_s3_keys)
    }


    it 'destroys all the emails' do
      expect(@emails).to have_received(:destroy_all)
    end

    it 'synchronizes the gmail ids' do
      expect(gmail_account).to have_received(:sync_gmail_ids)
    end

    it 'updates the draft_id of the draft email to the draft id of the draft data' do
      expect(email.draft_id).to eq( draft_data['id'] )
    end

    it 'updates the attachment upload email to the draft email' do
      expect(@email_attachment_upload.email).to eq(email)
    end

    it 'updates the attachment upload s3_key_full to the draft attachment_s3_key' do
      expect(@email_attachment_upload.s3_key_full).to eq(attachment_s3_keys.first)
    end
  end #__End of describe ".sync_draft_data"__

  describe ".create_draft" do
    let!(:email_raw) { "raw email" }
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, email: email) }
    let!(:draft_data) {
      {
        'id' => 'draft-id',
        'message' => {'id' => 'message-id'}
      }
    }

    before(:each) {
      @gmail_client = gmail_account.gmail_client

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:drafts_create) { draft_data }

      allow(gmail_account).to receive(:sync_draft_data) { draft_data }
    }

    context "when the email_in_reply_to exists" do
      before(:each) {
        allow(Email).to receive(:email_raw_from_params) { [email_raw, email] }

        gmail_account.create_draft(nil, nil, nil, nil, nil, nil, nil, nil)
      }

      it 'creates the draft data by the email_in_reply_to' do
        expect(@gmail_client).to have_received(:drafts_create)
      end
    end

    context "when the email_in_reply_to does not exist" do
      before(:each) {
        allow(Email).to receive(:email_raw_from_params) { [email_raw, nil] }

        gmail_account.create_draft(nil, nil, nil, nil, nil, nil, nil, nil)
      }

      it 'creates the draft data by the email_raw' do
        expect(@gmail_client).to have_received(:drafts_create)
      end
    end

    it 'returns the draft data' do
      expect( gmail_account.create_draft(nil, nil, nil, nil, nil, nil, nil, nil) ).to eq( draft_data )
    end
  end #__End of describe ".create_draft"__

  describe ".update_draft" do
    let!(:email_raw) { "raw email" }
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, email: email) }
    let!(:email_reference) { FactoryGirl.create(:email_reference, email: email) }
    let!(:draft_data) {
      {
        'id' => 'draft-id',
        'message' => {'id' => 'message-id'}
      }
    }

    before(:each) {
      @gmail_client = gmail_account.gmail_client
      @emails = Email.all
      @email_references = EmailReference.all
      @email_in_reply_tos = EmailInReplyTo.all

      allow(gmail_account).to receive(:emails) { @emails }
      allow(@emails).to receive(:find_by) { email }

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:drafts_update) { draft_data }

      allow(gmail_account).to receive(:sync_draft_data) { draft_data }
    }

    context "when couldn't get the email in reply to uid from the email references" do
      before(:each) {
        allow(email).to receive(:email_references) { @email_references }
        allow(@email_references).to receive(:order) { @email_references }
        allow(@email_references).to receive(:last) { email_reference }
        allow(email_reference).to receive(:email) { email }
        allow(email).to receive(:uid) { nil }

        allow(email).to receive(:email_in_reply_tos) { @email_in_reply_tos }

        gmail_account.update_draft(nil, nil, nil, nil, nil, nil, nil, nil)
      }

      it 'gets the uid from the email in reply tos' do
        expect(email).to have_received(:email_in_reply_tos)
      end
    end

    context "when the email_in_reply_to exists" do
      before(:each) {
        allow(Email).to receive(:email_raw_from_params) { [email_raw, email] }

        gmail_account.update_draft(nil, nil, nil, nil, nil, nil, nil, nil)
      }

      it 'creates the draft data by the email_in_reply_to' do
        expect(@gmail_client).to have_received(:drafts_update)
      end
    end

    context "when the email_in_reply_to does not exist" do
      before(:each) {
        allow(Email).to receive(:email_raw_from_params) { [email_raw, nil] }

        gmail_account.update_draft(nil, nil, nil, nil, nil, nil, nil, nil)
      }

      it 'creates the draft data by the email_raw' do
        expect(@gmail_client).to have_received(:drafts_update)
      end
    end

    it 'returns the draft data' do
      expect( gmail_account.update_draft(nil, nil, nil, nil, nil, nil, nil, nil) ).to eq( draft_data )
    end
  end #__End of describe ".update_draft"__

  describe ".send_draft" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:draft_id) { "draft-id" }

    context "when could not find the email by the draft id" do
      before(:each) {
        @emails = Email.all
        allow(gmail_account).to receive(:emails) { @emails }
        allow(@emails).to receive(:find_by_draft_id) { nil }
      }

      it 'returns nil' do
        expect( gmail_account.send_draft(draft_id) ).to be(nil)
      end
    end

    context "when could find the email by the draft id" do

      before(:each) {
        @email_raw =  GmailAccount.email_raw_from_gmail_data(gmail_data)
        @emails = Email.all
        allow(gmail_account).to receive(:emails) { @emails }
        allow(@emails).to receive(:find_by_draft_id) { email }
        allow(gmail_account).to receive(:email_raw_from_gmail_id) { @email_raw }
        allow(gmail_account).to receive(:google_o_auth2_token) { google_o_auth2_token }
        allow(google_o_auth2_token).to receive(:refresh)
        allow(@email_raw).to receive(:deliver!)
        allow(gmail_account).to receive(:delete_draft)
        allow(gmail_account).to receive(:sync_email)
        allow(@emails).to receive(:find_by_message_id) { email }
      }

      it 'refreshes the google auth token' do
        gmail_account.send_draft(draft_id)
        expect(google_o_auth2_token).to have_received(:refresh)
      end

      it 'delivers the email' do
        gmail_account.send_draft(draft_id)
        expect(@email_raw).to have_received(:deliver!)
      end

      it 'deletes the draft' do
        gmail_account.send_draft(draft_id)
        expect(gmail_account).to have_received(:delete_draft)
      end

      it 'synchronizes the email' do
        gmail_account.send_draft(draft_id)
        expect(gmail_account).to have_received(:sync_email)
      end

      it 'returns the email' do
        expect( gmail_account.send_draft(draft_id) ).to eq( email )
      end
    end
  end #__End of describe ".send_draft"__

  describe ".delete_draft" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:draft_id) { "draft-id" }

    before(:each) {
      @gmail_client = gmail_account.gmail_client
      @emails = Email.all

      allow(gmail_account).to receive(:gmail_client) { @gmail_client }
      allow(@gmail_client).to receive(:drafts_delete)
      allow(gmail_account).to receive(:emails) { @emails }
      allow(@emails).to receive(:find_by) { email }
      allow(email).to receive(:destroy)

      gmail_account.delete_draft(draft_id)
    }

    it 'deletes the drafts' do
      expect(@gmail_client).to have_received(:drafts_delete)
    end

    it 'destroys the email' do
      expect(email).to have_received(:destroy)
    end
  end #__End of describe ".delete_draft"__


  describe ".apply_cleaner" do

  end #__End of describe ".apply_cleaner"__










  describe '#destroy' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }

    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:people) { FactoryGirl.create_list(:person, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:gmail_labels) { FactoryGirl.create_list(:gmail_label, SpecMisc::TINY_LIST_SIZE, :gmail_account => gmail_account) }
    let!(:sync_failed_emails) { FactoryGirl.create_list(:sync_failed_email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }

    before { create_email_thread_emails(email_threads) }

    it 'should destroy the associated models' do
      expect(GoogleOAuth2Token.where(:google_api => gmail_account).count).to eq(1)
      expect(EmailThread.where(:email_account => gmail_account).count).to eq(email_threads.length)
      expect(Person.where(:email_account => gmail_account).count).to eq(people.length)
      expect(GmailLabel.where(:gmail_account => gmail_account).count).to eq(gmail_labels.length)
      expect(SyncFailedEmail.where(:email_account => gmail_account).count).to eq(sync_failed_emails.length)
      expect(Email.where(:email_account => gmail_account).count).to eq(email_threads.length * SpecMisc::TINY_LIST_SIZE)

      expect(gmail_account.destroy).not_to eq(false)

      expect(GoogleOAuth2Token.where(:google_api => gmail_account).count).to eq(0)
      expect(EmailThread.where(:email_account => gmail_account).count).to eq(0)
      expect(Person.where(:email_account => gmail_account).count).to eq(0)
      expect(GmailLabel.where(:gmail_account => gmail_account).count).to eq(0)
      expect(SyncFailedEmail.where(:email_account => gmail_account).count).to eq(0)
      expect(Email.where(:email_account => gmail_account).count).to eq(0)
    end
  end
end
