# == Schema Information
#
# Table name: email_rules
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  uid                     :text
#  from_address            :text
#  to_address              :text
#  subject                 :text
#  list_id                 :text
#  destination_folder_name :text
#  created_at              :datetime
#  updated_at              :datetime
#

require 'rails_helper'

describe EmailRule, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  # relationship
  it { should belong_to :user }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:from_address).of_type(:text)  }
  it { should have_db_column(:to_address).of_type(:text)  }
  it { should have_db_column(:subject).of_type(:text)  }
  it { should have_db_column(:list_id).of_type(:text)  }
  it { should have_db_column(:destination_folder_name).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  # indexes
  it { should have_db_index([:from_address, :to_address, :subject, :list_id, :destination_folder_name]).unique(true) }
  it { should have_db_index(:uid) }

  # validation
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:destination_folder_name) }
  it "populates the uid before validation" do
    email_rule = FactoryGirl.build(:email_rule, user: user, uid: nil)
     
    expect(email_rule.save).to be(true)
  end
  it "should add an error if the from_address, to_address, subject and list_id is blank" do
    email_rule = FactoryGirl.build(:email_rule, user: user, from_address: nil, to_address: nil, subject: nil, list_id: nil)
    email_rule.valid?
    email_rule.errors[:base].should eq(['This email rule is invalid because no criteria was specified.'])
  end
end
