# == Schema Information
#
# Table name: imap_folders
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe ImapFolder, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }

  # relationship
  it { should belong_to :email_account }
  it { should have_many(:email_folder_mappings).dependent(:destroy) }
  it { should have_many(:emails) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:email_account_id, :email_account_type, :name]).unique(true) }
  it { should have_db_index([:email_account_id, :email_account_type]) }

  # validation
  it { should validate_presence_of(:email_account_id) }
  it { should validate_presence_of(:email_account_type) }
  it { should validate_presence_of(:name) }
end
