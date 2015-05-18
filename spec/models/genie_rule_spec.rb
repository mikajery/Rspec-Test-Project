# == Schema Information
#
# Table name: genie_rules
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  from_address :text
#  to_address   :text
#  subject      :text
#  list_id      :text
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

describe GenieRule, :type => :model do
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
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:from_address, :to_address, :subject, :list_id]).unique(true) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:user) }
  it "populates the uid before validation" do
    genie_rule = FactoryGirl.build(:genie_rule, user: user, uid: nil)
    genie_rule.valid?
    expect(genie_rule.uid.nil?).to be(false)
  end
  it "should add an error if the from_address, to_address, subject and list_id is blank" do
    genie_rule = FactoryGirl.build(:genie_rule, user: user, from_address: nil, to_address: nil, subject: nil, list_id: nil)
    genie_rule.valid?
    genie_rule.errors[:base].should eq(['This genie rule is invalid because no criteria was specified.'])
  end
end
