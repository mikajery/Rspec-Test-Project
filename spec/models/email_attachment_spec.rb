# == Schema Information
#
# Table name: email_attachments
#
#  id                  :integer          not null, primary key
#  email_id            :integer
#  filename            :text
#  content_type        :text
#  file_size           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  uid                 :text
#  mime_type           :text
#  content_disposition :text
#  sha256_hex_digest   :text
#  gmail_attachment_id :text
#  s3_key              :text
#

require 'rails_helper'

describe EmailAttachment, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  # relationship
  it { should belong_to :email }

  # columns
  it { should have_db_column(:email_id).of_type(:integer)  }
  it { should have_db_column(:filename).of_type(:text)  }
  it { should have_db_column(:content_type).of_type(:text)  }
  it { should have_db_column(:file_size).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:mime_type).of_type(:text)  }
  it { should have_db_column(:content_disposition).of_type(:text)  }
  it { should have_db_column(:sha256_hex_digest).of_type(:text)  }
  it { should have_db_column(:gmail_attachment_id).of_type(:text)  }
  it { should have_db_column(:s3_key).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  # indexes
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:file_size) }
  it "populates the uid before validation" do
    email_attachment = FactoryGirl.build(:email_attachment, email: email, uid: nil)
     
    expect(email_attachment.save).to be(true)
  end
end
