# == Schema Information
#
# Table name: email_tracker_views
#
#  id                         :integer          not null, primary key
#  email_tracker_recipient_id :integer
#  uid                        :text
#  ip_address                 :text
#  user_agent                 :text
#  created_at                 :datetime
#  updated_at                 :datetime
#

require 'rails_helper'

RSpec.describe EmailTrackerView, :type => :model do
  let!(:email_tracker_recipient) { FactoryGirl.create(:email_tracker_recipient) }

  # relationship
  it { should belong_to :email_tracker_recipient }

  # columns
  it { should have_db_column(:email_tracker_recipient_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:ip_address).of_type(:text)  }
  it { should have_db_column(:user_agent).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index(:email_tracker_recipient_id) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:email_tracker_recipient) }
  it { should validate_presence_of(:ip_address) }
  it "populates the uid before validation" do
    email_tracker_view = FactoryGirl.create(:email_tracker_view, uid: nil)
    email_tracker_view.valid?
    expect(email_tracker_view.uid.nil?).to be(false)
  end
end
