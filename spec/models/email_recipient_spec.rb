# == Schema Information
#
# Table name: email_recipients
#
#  id             :integer          not null, primary key
#  email_id       :integer
#  person_id      :integer
#  recipient_type :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

describe EmailRecipient, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:person) { FactoryGirl.create(:person, :email_account => email.email_account) }

  # relationship
  it { should belong_to :email }
  it { should belong_to :person }

  # columns
  it { should have_db_column(:email_id).of_type(:integer)  }
  it { should have_db_column(:person_id).of_type(:integer)  }
  it { should have_db_column(:recipient_type).of_type(:integer)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  # indexes
  it { should have_db_index([:email_id, :person_id, :recipient_type]).unique(true) }
  it { should have_db_index(:email_id) }

  # validation
  it { should validate_presence_of(:email_id) }
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:recipient_type) }

  # enum
  it do
    should define_enum_for(:recipient_type).
      with({ :to => 0, :cc => 1, :bcc => 2 })
  end
end
