# == Schema Information
#
# Table name: email_signatures
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :text
#  name       :text
#  text       :text
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe EmailSignature, :type => :model do
  # relationship
  it { should belong_to :user }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:text).of_type(:text)  }
  it { should have_db_column(:html).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  let!(:user) { FactoryGirl.create(:user) }

  # validation
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:name) }
  it "populates the uid before validation" do
    email_signature = FactoryGirl.build(:email_signature, user: user, uid: nil)
     
    expect(email_signature.save).to be(true)
  end
end
