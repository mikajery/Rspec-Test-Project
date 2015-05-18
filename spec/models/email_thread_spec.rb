# == Schema Information
#
# Table name: email_threads
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  created_at         :datetime
#  updated_at         :datetime
#  emails_count       :integer
#

require 'rails_helper'

describe EmailThread, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_other) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }

  # relationship
  it { should belong_to :email_account }
  it { should have_many(:emails).dependent(:destroy) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:email_account_id, :email_account_type, :uid]).unique(true) }
  it { should have_db_index([:email_account_id, :email_account_type]) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:email_account) }
  it { should validate_presence_of(:uid) }

  # methods
  describe "#get_threads_from_ids" do

    it 'returns the email threads from the ids' do
      ids = email_threads.map(&:id).sample(3)
      expected = EmailThread.includes(:emails).where(:id => ids)
      
      expect(EmailThread.get_threads_from_ids(ids)).to eq(expected)
    end
  end #__End of describe "#get_threads_from_ids"__

  describe ".user" do

    it 'returns the user' do
      email_thread = email_threads.sample
      expected = email_thread.email_account.user

      expect(email_thread.user).to eq(expected)
    end
  end #__End of describe ".user"__

  context '#destroy' do
    let(:emails) { create_email_thread_emails(email_threads) }

    it 'should destroy the emails' do
      num_emails = emails.length
      expect(Email.where(:email_account => email_account).count).to eq(num_emails)

      email_threads.each do |email_thread|
        num_emails -= email_thread.emails.count
        expect(email_thread.destroy).not_to eq(false)
        expect(Email.where(:email_account => email_account).count).to eq(num_emails)
      end

      expect(Email.where(:email_account => email_account).count).to eq(0)
    end
  end
end
