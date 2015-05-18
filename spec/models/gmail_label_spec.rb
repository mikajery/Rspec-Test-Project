# == Schema Information
#
# Table name: gmail_labels
#
#  id                      :integer          not null, primary key
#  gmail_account_id        :integer
#  label_id                :text
#  name                    :text
#  message_list_visibility :text
#  label_list_visibility   :text
#  label_type              :text
#  created_at              :datetime
#  updated_at              :datetime
#  num_threads             :integer          default(0)
#  num_unread_threads      :integer          default(0)
#

require 'rails_helper'

describe GmailLabel, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let(:test_label) { FactoryGirl.create(:gmail_label, :gmail_account => email_account) }
  let(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }
  let(:emails_seen) { FactoryGirl.create_list(:seen_email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }

  # relationship
  it { should belong_to :gmail_account }

  it { should have_many(:email_folder_mappings).dependent(:destroy) }
  it { should have_many(:emails).through(:email_folder_mappings) }
  it { should have_many(:email_threads).through(:emails) }

  # columns
  it { should have_db_column(:gmail_account_id).of_type(:integer)  }
  it { should have_db_column(:label_id).of_type(:text)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:message_list_visibility).of_type(:text)  }
  it { should have_db_column(:label_list_visibility).of_type(:text)  }
  it { should have_db_column(:label_type).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }
  it { should have_db_column(:num_threads).of_type(:integer)  }
  it { should have_db_column(:num_unread_threads).of_type(:integer)  }

  # indexes
  it { should have_db_index([:gmail_account_id, :label_id]).unique(true) }
  it { should have_db_index([:gmail_account_id, :name]).unique(true) }
  it { should have_db_index(:gmail_account_id) }

  # validation
  it { should validate_presence_of(:gmail_account_id) }
  it { should validate_presence_of(:label_id) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:label_type) }

  # class methods
  describe "#skip_update_counts" do
    it 'returns the skip_update_counts' do
      expected = true
      GmailLabel.skip_update_counts = expected

      expect(GmailLabel.skip_update_counts).to eq(expected)
    end
  end #__End of describe "#skip_update_counts"__

  describe "#skip_update_counts=" do
    it 'sets the skip_update_counts' do
      expected = true
      GmailLabel.skip_update_counts = expected
      
      expect(GmailLabel.skip_update_counts).to eq(expected)
    end
  end #__End of describe "#skip_update_counts="__

  describe ".update_counts" do
    let(:gmail_label) { FactoryGirl.create(:gmail_label) }

    context "when the skip_update_counts is true" do
      it 'returns the nil' do
        GmailLabel.skip_update_counts = true

        expect(gmail_label.update_counts).to be(nil)
      end
    end

    context "when the skip_update_counts is false" do
      before(:each) {
        GmailLabel.skip_update_counts = false
      }

      it 'updates the num_threads and num_unread_threads fields' do

        folder_mappings = EmailFolderMapping.joins(:email)
        allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

        queried_mappings = folder_mappings.where(:email_folder => gmail_label)
        allow(folder_mappings).to receive(:where) { queried_mappings }

        mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
        unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

        gmail_label.update_counts

        expect(gmail_label.num_threads).to eq(mappings_count)
        expect(gmail_label.num_unread_threads).to eq(unread_count)
      end
    end #__End of context "when the skip_update_counts is false"__
  end #__End of describe ".update_counts"__

  describe "self.update_counts" do
    let(:gmail_label) { FactoryGirl.create(:gmail_label) }

    context "when the skip_update_counts is false" do
      before(:each) {
        GmailLabel.skip_update_counts = false
      }

      it 'updates the num_threads and num_unread_threads fields' do

        queried_mappings = EmailFolderMapping.joins(:email).
            where(:email_folder => gmail_label)

        mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
        unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

        GmailLabel.update_counts([gmail_label])

        expect(gmail_label.num_threads).to eq(mappings_count)
        expect(gmail_label.num_unread_threads).to eq(unread_count)
      end
    end #__End of context "when the skip_update_counts is false"__
  end

  describe ".update_num_unread_threads" do
    let(:gmail_label) { FactoryGirl.create(:gmail_label) }

    context "when the skip_update_counts is true" do
      it 'returns the nil' do
        GmailLabel.skip_update_counts = true

        expect(gmail_label.update_num_unread_threads).to be(nil)
      end
    end

    context "when the skip_update_counts is false" do
      before(:each) {
        GmailLabel.skip_update_counts = false
      }

      it 'updates the num_unread_threads field' do

        folder_mappings = EmailFolderMapping.joins(:email)
        allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

        queried_mappings = folder_mappings.where(:email_folder => gmail_label)
        allow(folder_mappings).to receive(:where) { queried_mappings }

        mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')
        allow(queried_mappings).to receive(:count) { mappings_count }

        gmail_label.update_num_unread_threads

        expect(gmail_label.num_unread_threads).to eq(mappings_count)
      end
    end #__End of context "when the skip_update_counts is false"__
  end #__End of describe ".update_num_unread_threads"__

  describe "self.update_num_unread_threads" do
    let(:gmail_label) { FactoryGirl.create(:gmail_label) }

    context "when the skip_update_counts is false" do
      before(:each) {
        GmailLabel.skip_update_counts = false
      }

      it 'updates the num_unread_threads field' do

        queried_mappings = EmailFolderMapping.joins(:email)
            .where(:email_folder => gmail_label)

        mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')

        GmailLabel.update_num_unread_threads([gmail_label])
        expect(gmail_label.num_unread_threads).to eq(mappings_count)
      end
    end #__End of context "when the skip_update_counts is false"__
  end #__End of describe ".update_num_unread_threads"__



  # describe '#num_threads' do
  #   it 'should return the correct number of threads' do
  #     # each email by default is assigned to a unique thread

  #     expect(test_label.num_threads).to eq(0)

  #     create_email_folder_mappings(emails, test_label)

  #     expect(test_label.num_threads).to eq(emails.length)

  #     create_email_folder_mappings(emails_seen, test_label)
  #     expect(test_label.num_threads).to eq(emails.length + emails_seen.length)
  #   end
  # end

  # describe '#num_unread_threads' do
  #   it 'should return the correct number of unread threads' do
  #     expect(test_label.num_unread_threads).to eq(0)

  #     create_email_folder_mappings(emails, test_label)

  #     expect(test_label.num_unread_threads).to eq(emails.length)

  #     create_email_folder_mappings(emails_seen, test_label)
  #     expect(test_label.num_unread_threads).to eq(emails.length)
  #   end
  # end
  
  describe '.get_sorted_paginated_threads' do
    let(:second_email_account) { FactoryGirl.create(:gmail_account) }
    let(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => second_email_account) }
    let(:email) { FactoryGirl.create(:email, :email_account => second_email_account) }

    context 'without emails' do
      it 'returns the empty result' do
        expect( gmail_label.get_sorted_paginated_threads(last_email_thread: nil, dir: 'DESC', threads_per_page: 50, log: true).length ).to eq(0)
      end

      context "when the emails of the gmail_label exist" do

        it 'returns the empty result' do
          email          
          allow(gmail_label).to receive(:emails) { Email.all }
          expect( gmail_label.get_sorted_paginated_threads.count ).to eq( 0 )
        end
      end
    end
    
    context 'with emails' do
      let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_label.gmail_account) }

      before { create_email_thread_emails(email_threads, email_folder: gmail_label, num_emails: SpecMisc::MEDIUM_LIST_SIZE, do_sleep: false) }
      
      it 'returns the email threads' do
        allow(EmailThread).to receive(:find_by_sql) { email_threads }

        expect( gmail_label.get_sorted_paginated_threads(last_email_thread: email_threads.last, dir: 'DESC', threads_per_page: 50, log: true).count ).to eq(email_threads.count)
      end
    end
  end #__End of describe ".get_sorted_paginated_threads"__

  describe '.apply_to_emails' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_thread) { FactoryGirl.create(:email_thread) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label) }
    let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder) }

    context "when the emails are given" do
      let(:emails) { [email] }

      it 'returns the email folder mapping array' do
        allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }
        
        expect( gmail_label.apply_to_emails(emails) ).to eq( [email_folder_mapping] )
      end
    end #__End of context "when the emails are given"__

    context "when the email ids are given" do
      let(:email_ids) { [email.id] }

      it 'returns the email folder mapping array' do
        allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }
        
        expect( gmail_label.apply_to_emails(email_ids) ).to eq( [email_folder_mapping] )
      end
    end #__End of context "when the email ids are given"__

    context "when the exception is raised" do
      it 'returns the array of the nil' do
        allow(EmailFolderMapping).to receive(:find_or_create_by!) { 
          FactoryGirl.create(:email, id: email.id)
        }

        expect( gmail_label.apply_to_emails([email]) ).to eq( [nil] )
      end
    end
  end #__End of describe ".apply_to_emails"__

  describe 'destroy' do
    let!(:email_account) { FactoryGirl.create(:gmail_account) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label, :gmail_account => email_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread,
                                                   SpecMisc::TINY_LIST_SIZE,
                                                   :email_account => email_account) }

    let!(:emails) { create_email_thread_emails(email_threads, email_folder: email_folder) }

    it 'should destroy the email folder mappings but not the emails' do
      expect(EmailThread.where(:email_account => email_account).count).to eq(email_threads.length)
      expect(Email.where(:email_account => email_account).count).to eq(emails.length)
      expect(EmailFolderMapping.where(:email_id => email_account.emails.pluck(:id)).count).to eq(emails.length)
      expect(email_account.gmail_labels.count).to eq(1)

      expect(email_folder.emails.count).to eq(emails.length)
      expect(email_folder.destroy).not_to eq(false)

      expect(EmailThread.where(:email_account => email_account).count).to eq(email_threads.length)
      expect(Email.where(:email_account => email_account).count).to eq(emails.length)
      expect(EmailFolderMapping.where(:email_id => email_account.emails.pluck(:id)).count).to eq(0)
      expect(email_account.gmail_labels.count).to eq(0)
    end
  end
end
