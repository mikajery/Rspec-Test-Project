# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  email_address      :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

describe Person, :type => :model do
  # relationship
  it { should belong_to :email_account }

  it { should have_many(:email_recipients).dependent(:destroy) }
  
  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:email_address).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:email_account_id, :email_account_type, :email_address]).unique(true) }
  it { should have_db_index([:email_address]) }
  it { should have_db_index(:name) }

  # validation
  it { should validate_presence_of(:email_account) }
  it { should validate_presence_of(:email_address) }
  it "cleans the email address before validation if the email address exists" do
    person = FactoryGirl.build(:person, email_address: FFaker::Internet.email)

    person.valid?
    
    expect(person.email_address).to eq(cleanse_email(person.email_address))
  end

  describe '#destroy' do
    let!(:person) { FactoryGirl.create(:person) }
    let!(:email_recipients) { FactoryGirl.create_list(:email_recipient, SpecMisc::MEDIUM_LIST_SIZE, :person => person) }

    it 'should destroy the associated models' do
      expect(EmailRecipient.where(:person => person).count).to eq(email_recipients.length)

      expect(person.destroy).not_to be(false)

      expect(EmailRecipient.where(:person => person).count).to eq(0)
    end
  end
end
