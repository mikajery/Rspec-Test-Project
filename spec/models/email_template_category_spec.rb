require 'rails_helper'

RSpec.describe EmailTemplateCategory, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  # relationship
  it { should belong_to :user }

  it { should have_many(:email_templates) }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:name).of_type(:text)  }
  it { should have_db_column(:email_templates_count).of_type(:integer)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index(:uid).unique(true) }
  it { should have_db_index([:user_id, :name]).unique(true) }

  # validation
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:name) }
  it "populates the uid before validation" do
    email_template_category = FactoryGirl.build(:email_template_category, user: user, uid: nil)

    expect(email_template_category.save).to be(true)
  end
end
