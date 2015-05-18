# == Schema Information
#
# Table name: email_templates
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

RSpec.describe EmailTemplate, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

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

  # indexes
  it { should have_db_index(:uid).unique(true) }
  it { should have_db_index([:user_id, :name]).unique(true) }

  # validation
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:name) }
  it "populates the uid before validation" do
    email_template = FactoryGirl.build(:email_template, user: user, uid: nil)
     
    expect(email_template.save).to be(true)
  end
end
