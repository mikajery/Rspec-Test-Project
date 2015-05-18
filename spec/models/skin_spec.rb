# == Schema Information
#
# Table name: skins
#
#  id         :integer          not null, primary key
#  uid        :text
#  name       :text
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Skin, :type => :model do
  # columns
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # validation
  it { should validate_presence_of(:name) }
  it "populates the uid before validation" do
    app = FactoryGirl.build(:skin, uid: nil)
     
    expect(app.save).to be(true)
  end
end
