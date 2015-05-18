# == Schema Information
#
# Table name: email_attachment_uploads
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  email_id    :integer
#  uid         :text
#  s3_key      :text
#  s3_key_full :text
#  filename    :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

describe EmailAttachmentUpload, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:email) { FactoryGirl.create(:email) }

  # relationship
  it { should belong_to :user }
  it { should belong_to :email }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:email_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:s3_key).of_type(:text)  }
  it { should have_db_column(:s3_key_full).of_type(:text)  }
  it { should have_db_column(:filename).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  # indexes
  it { should have_db_index(:s3_key).unique(true) }
  it { should have_db_index(:s3_key_full).unique(true) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:user) }
  it "populates the uid before validation" do
    email_attachment_upload = FactoryGirl.build(:email_attachment_upload, user: user, email: email, uid: nil)
     
    expect(email_attachment_upload.save).to be(true)
  end
  it "populates the s3_key before validation" do
    email_attachment_upload = FactoryGirl.build(:email_attachment_upload, user: user, email: email, s3_key: nil)
     
    expect(email_attachment_upload.save).to be(true)
  end

  # callback
  describe ":before_destroy" do
    
    context "when the s3_key exists" do
      let(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

      it "deletes the s3 before destroy" do

        allow(EmailAttachmentUpload).to receive(:delay).and_call_original
         
        email_attachment_upload.destroy
      end
    end
  end #__End of describe ":before_destroy"__

  # methods
  describe ".s3_path" do

    let!(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

    context 'when user is nil' do
      it "returns nil" do
        email_attachment_upload.user = nil
        expect(email_attachment_upload.s3_path).to be(nil)
      end
    end
    
    context 'when s3_key is nil' do
      it "returns nil" do
        email_attachment_upload.s3_key = nil
        expect(email_attachment_upload.s3_path).to be(nil)
      end
    end

    it "returns the s3 path" do
      expected = "uploads/#{email_attachment_upload.user.id}/#{email_attachment_upload.s3_key}/#{email_attachment_upload.filename}"
      expect(email_attachment_upload.s3_path).to eq(expected)
    end
  end #__End of describe ".s3_path"__

  describe ".presigned_post" do

    let!(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

    context 'when user is nil' do
      it "returns nil" do
        email_attachment_upload.user = nil
        expect(email_attachment_upload.s3_path).to be(nil)
      end
    end
    
    context 'when s3_key is nil' do
      it "returns nil" do
        email_attachment_upload.s3_key = nil
        expect(email_attachment_upload.s3_path).to be(nil)
      end
    end

    it "returns the presigned_post" do
      expect(email_attachment_upload.presigned_post.class).to eq(AWS::S3::PresignedPost)
    end
  end #__End of describe ".presigned_post"__
end
