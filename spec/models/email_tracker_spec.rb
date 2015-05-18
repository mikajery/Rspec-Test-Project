# == Schema Information
#
# Table name: email_trackers
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  email_uids         :text
#  email_subject      :text
#  email_date         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe EmailTracker, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }

  # relationship
  it { should belong_to :email_account }
  it { should have_many(:email_tracker_recipients).dependent(:destroy) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:email_uids).of_type(:text)  }
  it { should have_db_column(:email_subject).of_type(:text)  }
  it { should have_db_column(:email_date).of_type(:datetime)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index(:email_account_id) }
  it { should have_db_index(:uid).unique(true) }

  # serialize
  it { should serialize(:email_uids) }

  # validation
  it { should validate_presence_of(:email_account) }
  it { should validate_presence_of(:email_subject) }
  it { should validate_presence_of(:email_date) }
  it "populates the uid before validation" do
    email_tracker = FactoryGirl.create(:email_tracker, uid: nil)
    
    expect(email_tracker.valid?).to be(true)
  end
end
