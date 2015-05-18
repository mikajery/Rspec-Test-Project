# == Schema Information
#
# Table name: emails
#
#  id                                :integer          not null, primary key
#  email_account_id                  :integer
#  email_account_type                :string(255)
#  email_thread_id                   :integer
#  ip_info_id                        :integer
#  auto_filed                        :boolean          default(FALSE)
#  auto_filed_reported               :boolean          default(FALSE)
#  auto_filed_folder_id              :integer
#  auto_filed_folder_type            :string(255)
#  uid                               :text
#  draft_id                          :text
#  message_id                        :text
#  list_name                         :text
#  list_id                           :text
#  seen                              :boolean          default(FALSE)
#  snippet                           :text
#  date                              :datetime
#  from_name                         :text
#  from_address                      :text
#  sender_name                       :text
#  sender_address                    :text
#  reply_to_name                     :text
#  reply_to_address                  :text
#  tos                               :text
#  ccs                               :text
#  bccs                              :text
#  subject                           :text
#  html_part                         :text
#  text_part                         :text
#  body_text                         :text
#  has_calendar_attachment           :boolean          default(FALSE)
#  list_subscription_id              :integer
#  bounce_back                       :boolean          default(FALSE)
#  bounce_back_time                  :datetime
#  bounce_back_type                  :text
#  bounce_back_job_id                :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  auto_file_folder_name             :string(255)
#  queued_auto_file                  :boolean          default(FALSE)
#  upload_attachments_delayed_job_id :integer
#  attachments_uploaded              :boolean          default(FALSE)
#

require 'rails_helper'
require 'stringio'

describe Email, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_thread) { FactoryGirl.create(:email_thread) }
  let!(:ip_info) { FactoryGirl.create(:ip_info) }
  let!(:auto_filed_folder) { FactoryGirl.create(:gmail_label) }
  let!(:list_subscription) { FactoryGirl.create(:list_subscription, email_account: email_account) }
  let!(:email_folder) { FactoryGirl.create(:gmail_label) }
  let!(:previous_email) { FactoryGirl.create(:email) }

  # relationship
  it { should belong_to :email_account }
  it { should belong_to :email_thread }
  it { should belong_to :ip_info }
  it { should belong_to :auto_filed_folder }
  it { should belong_to :list_subscription }

  it { should have_many(:email_folder_mappings).dependent(:destroy) }
  it { should have_many(:imap_folders).through(:email_folder_mappings).source(:email_folder) }
  it { should have_many(:gmail_labels).through(:email_folder_mappings).source(:email_folder) }
  it { should have_many(:email_recipients).dependent(:destroy) }
  it { should have_many(:email_references).dependent(:destroy) }
  it { should have_many(:email_in_reply_tos).dependent(:destroy) }
  it { should have_many(:email_attachments).dependent(:destroy) }
  it { should have_many(:email_tracker_recipients).dependent(:destroy) }
  it { should have_many(:email_tracker_views).through(:email_tracker_recipients) }
  it { should have_many(:email_attachment_uploads) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:email_thread_id).of_type(:integer)  }
  it { should have_db_column(:ip_info_id).of_type(:integer)  }
  it { should have_db_column(:auto_filed).of_type(:boolean)  }
  it { should have_db_column(:auto_filed_reported).of_type(:boolean)  }
  it { should have_db_column(:auto_filed_folder_id).of_type(:integer)  }
  it { should have_db_column(:auto_filed_folder_type).of_type(:string)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:draft_id).of_type(:text)  }
  it { should have_db_column(:message_id).of_type(:text)  }
  it { should have_db_column(:list_name).of_type(:text)  }
  it { should have_db_column(:list_id).of_type(:text)  }
  it { should have_db_column(:seen).of_type(:boolean)  }
  it { should have_db_column(:snippet).of_type(:text)  }
  it { should have_db_column(:date).of_type(:datetime)  }
  it { should have_db_column(:from_name).of_type(:text)  }
  it { should have_db_column(:from_address).of_type(:text)  }
  it { should have_db_column(:sender_name).of_type(:text)  }
  it { should have_db_column(:sender_address).of_type(:text)  }
  it { should have_db_column(:reply_to_name).of_type(:text)  }
  it { should have_db_column(:reply_to_address).of_type(:text)  }
  it { should have_db_column(:tos).of_type(:text)  }
  it { should have_db_column(:ccs).of_type(:text)  }
  it { should have_db_column(:bccs).of_type(:text)  }
  it { should have_db_column(:subject).of_type(:text)  }
  it { should have_db_column(:html_part).of_type(:text)  }
  it { should have_db_column(:text_part).of_type(:text)  }
  it { should have_db_column(:body_text).of_type(:text)  }
  it { should have_db_column(:has_calendar_attachment).of_type(:boolean)  }
  it { should have_db_column(:list_subscription_id).of_type(:integer)  }
  it { should have_db_column(:bounce_back).of_type(:boolean)  }
  it { should have_db_column(:bounce_back_time).of_type(:datetime)  }
  it { should have_db_column(:bounce_back_type).of_type(:text)  }
  it { should have_db_column(:bounce_back_job_id).of_type(:integer)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }
  it { should have_db_column(:auto_file_folder_name).of_type(:string)  }
  it { should have_db_column(:queued_auto_file).of_type(:boolean)  }
  it { should have_db_column(:upload_attachments_delayed_job_id).of_type(:integer)  }
  it { should have_db_column(:attachments_uploaded).of_type(:boolean)  }

  # indexes
  it { should have_db_index([:date, :id]) }
  it { should have_db_index(:date) }
  it { should have_db_index([:email_account_id, :email_account_type, :draft_id]).unique(true) }
  it { should have_db_index([:email_account_id, :email_account_type, :uid]).unique(true) }
  it { should have_db_index([:email_account_id, :email_account_type]) }
  it { should have_db_index(:email_thread_id) }
  it { should have_db_index(:from_address) }
  it { should have_db_index(:id) }
  it { should have_db_index(:message_id) }
  it { should have_db_index(:reply_to_address) }
  it { should have_db_index(:sender_address) }
  it { should have_db_index(:uid).unique(true) }

  # enum
  it do
    should define_enum_for(:bounce_back_type).
      with({:always => 'always', :not_opened => 'not_opened', :not_clicked => 'not_clicked', :no_reply => 'no_reply'})
  end

  # validation
  it { should validate_presence_of(:email_account) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:email_thread_id) }

  # callback
  it "updates the folder_email_thread_date of the EmailFolderMapping after create" do
    email_folder_mapping = FactoryGirl.create(:email_folder_mapping, email: previous_email, email_thread: email_thread, email_folder: email_folder)

    email = FactoryGirl.create(:email, email_thread: email_thread)

    expected = DateTime.parse(email.email_thread.emails.maximum(:date).to_s)

    expect( DateTime.parse(email_folder_mapping.reload.folder_email_thread_date.to_s) ).to eq(expected)
  end

  it "calls the update_num_unread_threads of the gmail_label after update and seen changed" do
    3.times do
      email_folder_mapping = FactoryGirl.create(:email_folder_mapping, email: previous_email, email_thread: email_thread)
    end

    previous_email.reload.gmail_labels.each do |gmail_label|
      gmail_label.should_receive(:update_num_unread_threads)
    end

    previous_email.seen = (not previous_email.seen)
    previous_email.save
  end

  describe ".update_sync_time" do
    let!(:email) { FactoryGirl.create(:email) }

    it 'updates the last synchronzied time of the email account' do
      email.update_sync_time
      expect( email.updated_at ).to eq(email.email_account.last_sync_at)
    end
  end

  describe '#Email.lists_email_daily_average' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }

    context 'without emails' do
      it 'returns the lists report stats' do
        lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user)
        expect(lists_email_daily_average.length).to eq(0)
      end
    end

    context 'with emails' do
      let!(:today) { DateTime.now.utc }
      let!(:yesterday) { today - 2.day }

      let!(:today_str) { today.strftime($config.volume_report_date_format) }
      let!(:yesterday_str) { yesterday.strftime($config.volume_report_date_format) }

      let(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }

      before do
        email_threads.each_with_index do |email_thread, i|
          FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                  :email_thread => email_thread,
                                  :email_account => gmail_account,
                                  :date => today,
                                  :list_id => "foo#{i}.bar.com")

          FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE * (i + 1),
                                  :email_thread => email_thread,
                                  :email_account => gmail_account,
                                  :date => yesterday,
                                  :list_id => "foo#{i}.bar.com")
        end
      end

      it 'returns the lists report stats' do
        lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user)

        lists_email_daily_average.each do |list_email_daily_average|
          i = list_email_daily_average[1].match(/(\d)/)[1].to_i
          expect(list_email_daily_average[2]).to eq((SpecMisc::TINY_LIST_SIZE + SpecMisc::TINY_LIST_SIZE * (i + 1)) / 2.0)
        end
      end
    end
  end

  describe '#Email.email_raw_from_params' do
    let!(:email_raw) { Mail.new }
    let!(:parent_email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, :email => parent_email) }
    let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => parent_email) }
    let!(:attachment_s3_key) { "s3-test-key" }

    context "when the attachment_s3_keys is given" do
      let!(:email_raw) {
        Mail.new do
          to nil
          cc nil
          bcc nil
          subject nil
        end
      }

      before do
        allow(Mail).to receive(:new) { email_raw }
        allow_any_instance_of(AWS::S3::S3Object).to receive(:read).and_return([true])
        allow(email_raw).to receive(:add_file)
        allow(FileUtils).to receive(:remove_entry_secure)
      end

      it 'adds new file to the raw email' do        
        email_raw_result, email_in_reply_to = Email.email_raw_from_params('to@to.com', 'cc@cc.com', 'bcc@bcc.com',
                                                                 'subject', 'html_part', 'text_part',
                                                                 parent_email.email_account, parent_email.uid, [attachment_s3_key])

        expect(email_raw_result).to have_received(:add_file)
      end

      it 'removes the entry' do
        expect(FileUtils).to receive(:remove_entry_secure)

        email_raw_result, email_in_reply_to = Email.email_raw_from_params('to@to.com', 'cc@cc.com', 'bcc@bcc.com',
                                                                 'subject', 'html_part', 'text_part',
                                                                 parent_email.email_account, parent_email.uid, [attachment_s3_key])

      end
    end

    it 'creates the email' do
      email_raw, email_in_reply_to = Email.email_raw_from_params('to@to.com', 'cc@cc.com', 'bcc@bcc.com',
                                                                 'subject', 'html_part', 'text_part',
                                                                 parent_email.email_account, parent_email.uid)
      expect(email_raw.to).to eq(['to@to.com'])
      expect(email_raw.cc).to eq(['cc@cc.com'])
      expect(email_raw.bcc).to eq(['bcc@bcc.com'])
      expect(email_raw.subject).to eq('subject')
      expect(email_raw.html_part.decoded).to eq('html_part')
      expect(email_raw.text_part.decoded).to eq('text_part')

      # reply headers
      expect(email_raw.in_reply_to).to eq(parent_email.message_id)

      expect(email_raw.references.length).to eq(email_references.length + 1)

      email_references.each_with_index do |email_reference, position|
        expect(email_raw.references[position]).to eq(email_reference.references_message_id)
      end

      expect(email_raw.references.last).to eq(parent_email.message_id)
    end
  end

  describe 'Email creation' do
    def validate_default_email(email)
      # expect(email.ip_info.ip).to eq('50.197.164.77')

      expect(email.message_id).to eq('CAGxZP2OiRss-xbvSM4T48FdK=EmbdSyiOGDjXnk+mS6o5x50qA@mail.gmail.com')

      expect(email.list_name).to eq('The virtual soul of the Black Community at Stanford')
      expect(email.list_id).to eq('the_diaspora.lists.stanford.edu')

      expect(email.date).to eq('Thu, 18 Sep 2014 22:42:32 -0700')

      expect(email.from_name).to eq('Qounsel Digest')
      expect(email.from_address).to eq('digest@mail.qounsel.com')

      expect(email.sender_name).to eq('activists')
      expect(email.sender_address).to eq('activists-bounces@lists.stanford.edu')

      expect(email.reply_to_name).to eq('Reply to Comment')
      expect(email.reply_to_address).to eq('g+40wvnfci000000004t3f0067f3d796km0000009ooypx2pu46@groups.facebook.com')

      expect(email.tos).to eq('test@turinginc.com')
      expect(email.ccs).to eq('cc@cc.com')
      expect(email.bccs).to eq('bcc@bcc.com')
      expect(email.subject).to eq('test')

      expect(email.text_part).to eq("body\n")
      verify_premailer_html(email.html_part, "body\n")
      expect(email.body_text).to eq(nil)

      expect(email.has_calendar_attachment).to eq(true)
    end

    describe '#Email.email_raw_from_mime_data' do
      let(:mime_data) { File.read('spec/data/emails/raw/raw_email.txt') }
      let(:email_raw) { Email.email_raw_from_mime_data(mime_data) }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should load the email' do
        validate_default_email(email)
      end
    end

    describe '#Email.email_from_mime_data' do
      let(:mime_data) { File.read('spec/data/emails/raw/raw_email.txt') }
      let(:email) { Email.email_from_mime_data(mime_data) }

      it 'should load the email' do
        validate_default_email(email)
      end
    end

    describe '#Email.email_from_email_raw' do
      let(:email_raw) { Mail.read('spec/data/emails/raw/raw_email.txt') }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should load the email' do
        validate_default_email(email)
      end

      context "when the raw email is not multipart" do
        context "when the content_type is nil" do
          it 'saves the body_text field of new email' do
            raw_email = Mail::Message.new
            expected = premailer_html(raw_email.decoded.force_utf8(true))
            result_email = Email.email_from_email_raw(raw_email)

            expect( result_email.body_text ).to eq( expected )
          end
        end
      end
    end
  end

  context '#Email.get_sender_ip' do
    context 'X-Originating-IP' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/x_originating_ip.txt') }

      it 'should get the sender IP from the X-Originating-IP header' do
        expect(Email.get_sender_ip(email_raw)).to eq('50.197.164.77')
      end
    end

    context 'Received-SPF' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/received_spf.txt') }

      it 'should get the sender IP from the Received-SPF header' do
        expect(Email.get_sender_ip(email_raw)).to eq('10.112.11.170')
      end
    end

    context 'Received' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/received.txt') }

      it 'should get the sender IP from the Received header' do
        allow_any_instance_of(Mail::Field).to receive(:value).and_return("from.[66.220.144.136]")

        expect(Email.get_sender_ip(email_raw)).to eq('66.220.144.136')
      end
    end
  end

  describe '#Email.part_has_calendar_attachment' do
    context 'has calendar attachment' do
      let(:email_raw) { Mail.read("spec/data/emails/calendar/has_calendar_attachment.txt") }

      it 'returns true' do
        expect(Email.part_has_calendar_attachment(email_raw)).to be(true)
      end
    end

    context 'no calendar attachment' do
      let(:email_raw) { Mail.read("spec/data/emails/calendar/no_calendar_attachment.txt") }

      it 'returns false' do
        expect(Email.part_has_calendar_attachment(email_raw)).to be(false)
      end
    end
  end

  describe '#Email.add_reply_headers' do
    let!(:email_raw) { Mail.new }
    let!(:parent_email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, :email => parent_email) }

    context 'has references' do
      let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => parent_email) }

      before { Email.add_reply_headers(email_raw, parent_email) }

      it 'should add the reply headers' do
        expect(email_raw.in_reply_to).to eq(parent_email.message_id)

        expect(email_raw.references.length).to eq(email_references.length + 1)

        email_references.each_with_index do |email_reference, position|
          expect(email_raw.references[position]).to eq(email_reference.references_message_id)
        end

        expect(email_raw.references.last).to eq(parent_email.message_id)
      end
    end

    context 'no references' do
      before { Email.add_reply_headers(email_raw, parent_email) }

      it 'should add the reply headers' do
        expect(email_raw.in_reply_to).to eq(parent_email.message_id)

        expect(email_raw.references.length).to eq(2)
        expect(email_raw.references[0]).to eq(email_in_reply_to.in_reply_to_message_id)
        expect(email_raw.references[1]).to eq(parent_email.message_id)
      end
    end
  end

  describe '#user' do
    let(:email) { FactoryGirl.create(:email) }

    it 'returns the user' do
      expect(email.user).not_to be(nil)
    end
  end

  describe '#add_references' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.new }

    context 'valid references' do
      before { email_raw.header = File.read('spec/data/emails/headers/references/valid_references.txt') }
      before { email.add_references(email_raw) }

      it 'should add the references' do
        email_references = email.email_references.order(:position).pluck(:references_message_id)
        expect(email_references).to eq(['CAMwYsmtfTu-kF3c8WS6ioxatGAg+S9wYPmZVK9M3KvNLO_HRiw@mail.gmail.com',
                                        'CA+nRABmhcoTqWQvDcF--OkDGj6DkA8Ttc4eYOgKZW=EAp-5Ejw@mail.gmail.com',
                                        'CAMwYsmseaXEqWnxuNrjd0rmSrEkcCF5n9usAOhmt-xsqwBWLPA@mail.gmail.com'])
      end
    end

    context 'invalid reference' do
      before { email_raw.header = File.read('spec/data/emails/headers/references/invalid_reference.txt') }
      before { email.add_references(email_raw) }

      it 'should add the reference' do
        expect(email.email_references.first.references_message_id).to eq('hello')
      end
    end
  end

  describe '#add_in_reply_tos' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.new }

    context 'valid reply_to' do
      before { email_raw.header = File.read('spec/data/emails/headers/in_reply_tos/valid_reply_to.txt') }
      before { email.add_in_reply_tos(email_raw) }

      it 'should add the references' do
        expect(email.email_in_reply_tos.first.in_reply_to_message_id).to eq('CAMwYsmseaXEqWnxuNrjd0rmSrEkcCF5n9usAOhmt-xsqwBWLPA@mail.gmail.com')
      end
    end

    context 'invalid reply_to' do
      before { email_raw.header = File.read('spec/data/emails/headers/in_reply_tos/invalid_reply_to.txt') }
      before { email.add_in_reply_tos(email_raw) }

      it 'should add the reference' do
        expect(email.email_in_reply_tos.first.in_reply_to_message_id).to eq('hello')
      end
    end

    context 'reply_to class is not string' do
      let!(:in_reply_to_message_id) { "in-reply-to-message-id" }

      it 'should add the references' do
        allow(email_raw).to receive(:in_reply_to) { [in_reply_to_message_id] }

        email.add_in_reply_tos(email_raw)

        expect(email.email_in_reply_tos.first.in_reply_to_message_id).to eq(in_reply_to_message_id)
      end
    end
  end

  describe '#add_attachments' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.read("spec/data/emails/with_attachments/email_1.txt") }

    it 'should correctly add attachments' do
      email.add_attachments(email_raw)

      email.reload
      email_attachment = email.email_attachments.first
      expect(email_attachment.filename).to eq('Health Promotions Specialist FTR92014 - APIWC.pdf')
      expect(email_attachment.content_type).to eq('application/pdf')
      expect(email_attachment.file_size).to eq(92918)
    end

    context "when the raw email is not multipart" do
      context "when the content_type is not text" do
        before(:each) {
          @raw_email = Mail::Message.new
          @raw_email.content_type = "image/message"
        }

        it 'adds the raw email as attachments' do
          allow(email).to receive(:add_attachment)

          email.add_attachments(@raw_email)

          expect(email).to have_received(:add_attachment)
        end
      end
    end
  end

  describe '#add_recipients' do
    let(:recipients_expected) {
      {
          '1' => {
              :tos => [{ :name => 'the diaspora', :email_address => 'the_diaspora@lists.stanford.edu' },
                       { :name => nil, :email_address => 'sbse@lists.stanford.edu'} ],
              :ccs => [],
              :bccs => []
          },

          '2' => {
              :tos => [{ :name => 'Sam Bydlon', :email_address => 'sbydlon@stanford.edu' }],
              :ccs => [{ :name => 'gsc-members', :email_address => 'gsc-members@lists.stanford.edu' }],
              :bccs => []
          },

          '3' => {
              :tos => [],
              :ccs => [],
              :bccs => [{ :name => nil, :email_address => 'support@sendpluto.com' }]
          }
      }
    }

    it 'should correctly add recipients' do
      recipients_expected.each do |key, recipients|
        email = FactoryGirl.create(:email)
        email_raw = Mail.new
        email_raw.header = File.read("spec/data/emails/headers/recipients/recipients_#{key}.txt")

        email.add_recipients(email_raw)

        [['to', :tos], ['cc', :ccs], ['bcc', :bccs]].each do |recipient_scope, recipient_type|
          expect(email.email_recipients.send(recipient_scope).count).to eq(recipients[recipient_type].length)

          recipients[recipient_type].each do |recipient_expected|
            found = false

            email.email_recipients.send(recipient_scope).each do |recipient|
              found = recipient_expected[:name] == recipient.person.name &&
                      recipient_expected[:email_address] == recipient.person.email_address
              break if found
            end

            expect(found).to eq(true)
          end
        end
      end
    end
  end

  describe ".add_recipient" do

  end

  describe ".run_bounce_back" do
    let!(:email) { FactoryGirl.create(:email, bounce_back: true) }

    context "when the bounce_back is false" do
      before(:each) {
        email.bounce_back = false
      }

      it 'returns nil' do
        expect( email.run_bounce_back ).to be(nil)
      end
    end

    context "when the bounce_back is true" do
      before do
        $stdout = StringIO.new
        allow(email).to receive(:email_account) { email_account }
        allow(email_account).to receive(:apply_label_to_email)
      end

      after(:all) do
        $stdout = STDOUT
      end

      context "when the bounce_back_type is always" do
        before(:each) {
          email.bounce_back_type = Email.bounce_back_types[:always]
          email.run_bounce_back
        }

        it "logs 'bounce back ALWAYS!!'" do
          expect($stdout.string).to match(/bounce back ALWAYS!!/)
        end

        it 'applys the label to the email' do
          expect(email_account).to have_received(:apply_label_to_email)
        end

      end

      context "when the bounce_back_type is no_reply" do
        before(:each) {
          email.bounce_back_type = Email.bounce_back_types[:no_reply]
          email.run_bounce_back
        }

        it "logs 'bounce back NO reply!!'" do
          expect($stdout.string).to match(/bounce back NO reply!!/)
        end

        it 'applys the label to the email' do
          expect(email_account).to have_received(:apply_label_to_email)
        end
      end

      context "when the bounce_back_type is not_opened" do
        before(:each) {
          email.bounce_back_type = Email.bounce_back_types[:not_opened]
          email.run_bounce_back
        }

        it "logs 'bounce back UNOPENED!!'" do
          expect($stdout.string).to match(/bounce back UNOPENED!!/)
        end

        it 'applys the label to the email' do
          expect(email_account).to have_received(:apply_label_to_email)
        end
      end
    end #__End of context "when the bounce_back is true"__
  end #__End of describe ".run_bounce_back"__

  describe ".get_attachments_from_gmail_data" do
    let!(:email) { FactoryGirl.create(:email) }
    let(:attachments) { ["attachment"] }

    context "when the parts_data is nil" do
      it 'returns the attachments' do
        expect( email.get_attachments_from_gmail_data(nil, nil, attachments) ).to eq( attachments )
      end
    end

    context "when the parts_data is not nil" do
      let(:parts_data) { ["part"] }

      it 'returns the attachments' do
        expect( email.get_attachments_from_gmail_data(nil, parts_data, attachments) ).to eq( attachments )
      end

      context "when the filename and body exist" do
        let!(:part) {
          {
            'filename' => "file name",
            'mimeType' => "mime type",
            'body' => {
                        'attachmentId' => "attachment-id"
                      }
          }
        }
        let(:parts_data) { [part] }
        let(:attachment_json) do
          {
            'data' => "attachment data"
          }
        end

        before do
          allow_any_instance_of(Google::GmailClient).to receive(:attachments_get).and_return(attachment_json)
          allow(Base64).to receive(:urlsafe_decode64) { attachment_json['data'] }
          allow_any_instance_of(AWS::S3::S3Object).to receive(:write)
        end

        it 'creates new instance of the email attachment with the proper attributes' do
          email_attachment = email.get_attachments_from_gmail_data(nil, parts_data, attachments).last

          body = part['body']
          sha256_hex_digest = Digest::SHA256.hexdigest(attachment_json['data'])

          expect( email_attachment.email ).to eq( email )
          expect( email_attachment.filename ).to eq( part['filename'] )
          expect( email_attachment.mime_type ).to eq( part['mimeType'] )
          expect( email_attachment.gmail_attachment_id ).to eq( body['attachmentId'] )
          expect( email_attachment.file_size ).to eq( attachment_json['data'].length )
          expect( email_attachment.sha256_hex_digest ).to eq( sha256_hex_digest )
        end

        context "when the headers of the part exists" do
          context "when the header name is 'content-type'" do
            before(:each) do
              part['headers'] = [
                {
                  'name' => 'content-type',
                  'value' => "mpeg"
                }
              ]
            end

            it 'sets up the content_type field with the header value' do
              expected = part['headers'].first['value'].split(';')[0].downcase.strip

              result = email.get_attachments_from_gmail_data(nil, parts_data, attachments).last

              expect( result.content_type ).to eq( expected )
            end
          end

          context "when the header name is 'content-disposition'" do
            before(:each) do
              part['headers'] = [
                {
                  'name' => 'content-disposition',
                  'value' => "mpeg"
                }
              ]
            end

            it 'sets up the content_disposition field with the header value' do
              expected = part['headers'].first['value'].split(';')[0].downcase.strip

              result = email.get_attachments_from_gmail_data(nil, parts_data, attachments).last

              expect( result.content_disposition ).to eq( expected )
            end
          end
        end

        context "when the part body data exists" do
          before(:each) {
            part['body']['data'] = "body data"

            allow(Base64).to receive(:decode64) { part['body']['data'] }
          }

          it 'creates new instance of the email attachment with the proper attributes' do
            email_attachment = email.get_attachments_from_gmail_data(nil, parts_data, attachments).last

            sha256_hex_digest = Digest::SHA256.hexdigest(part['body']['data'])

            expect( email_attachment.file_size ).to eq( part['body']['data'].length )
            expect( email_attachment.sha256_hex_digest ).to eq( sha256_hex_digest )
          end
        end

        it 'removes the entiry secure' do
          allow(FileUtils).to receive(:remove_entry_secure)

          email.get_attachments_from_gmail_data(nil, parts_data, attachments)

          expect(FileUtils).to have_received(:remove_entry_secure)
        end

        it 'pushes the email attachement' do
          expect(email.get_attachments_from_gmail_data(nil, parts_data, attachments).last).to be_an_instance_of(EmailAttachment)
        end
      end #__End of context "when the filename and bocy exist"__
    end #__End of context "when the parts_data is not nil"__
  end #__End of describe ".get_attachments_from_gmail_data"__

  describe ".upload_attachments" do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_attachment) { FactoryGirl.create(:email_attachment, :email => email) }
    let(:gmail_data) do
      {
        'payload' => {'parts' => 'gmail parts'}
      }
    end
    let!(:new_attachment) { "new attachment" }

    before(:each) {
      @email_attachments = EmailAttachment.all

      allow_any_instance_of(Google::GmailClient).to receive(:messages_get).and_return(gmail_data)
      allow(email).to receive(:get_attachments_from_gmail_data) { [email_attachment] }

      allow(email).to receive(:email_attachments) { @email_attachments }
      allow(@email_attachments).to receive(:destroy_all)
      allow_any_instance_of(EmailAttachment).to receive(:save!)

      email.upload_attachments
    }

    it 'destroys all the email attachements of the email' do
      expect(@email_attachments).to have_received(:destroy_all)
    end
  end #__End of describe ".upload_attachments"__

  describe '#destroy' do
    let(:email) { FactoryGirl.create(:email) }

    let!(:email_recipients) { FactoryGirl.create_list(:email_recipient, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_in_reply_tos) { FactoryGirl.create_list(:email_in_reply_to, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_attachments) { FactoryGirl.create_list(:email_attachment, SpecMisc::TINY_LIST_SIZE, :email => email) }

    before { create_email_folder_mappings([email]) }

    it 'should destroy the associated models' do
      email.reload
      expect(EmailFolderMapping.where(:email => email).count).to eq(1)
      expect(EmailRecipient.where(:email => email).count).to eq(email_recipients.length)
      expect(EmailReference.where(:email => email).count).to eq(email_references.length)
      expect(EmailInReplyTo.where(:email => email).count).to eq(email_in_reply_tos.length)
      expect(EmailAttachment.where(:email => email).count).to eq(email_attachments.length)

      expect(email.destroy).not_to be(false)

      expect(EmailFolderMapping.where(:email => email).count).to eq(0)
      expect(EmailRecipient.where(:email => email).count).to eq(0)
      expect(EmailReference.where(:email => email).count).to eq(0)
      expect(EmailInReplyTo.where(:email => email).count).to eq(0)
      expect(EmailAttachment.where(:email => email).count).to eq(0)
    end
  end
end
