require 'rails_helper'

describe StaticPagesHelper, :type => :helper do
  describe '#upload_attachment_post' do

    context 'when the user is NOT signed in' do

      it 'raises the error' do
        expect { helper.upload_attachment_post }.to raise_error
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { 
        helper.sign_in(user)
      }

      it 'creates new EmailAttachmentUpload' do
        expect(EmailAttachmentUpload.count).to eq(0)
        helper.upload_attachment_post
        expect(EmailAttachmentUpload.count).to eq(1)
      end

      it 'returns the presigned post url' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()
        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post).and_return(presigned_post)

        result = helper.upload_attachment_post
        expect(result[:url]).to eq(presigned_post.url.to_s)
      end

      it 'returns the fiels of the presigned post' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()
        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post).and_return(presigned_post)

        result = helper.upload_attachment_post
        expect(result[:fields]).to eq(presigned_post.fields)
      end
    end #__End of context "when the user is signed in"__
    
  end #__End of describe "#upload_attachment_post"__

  describe '#email_folders' do
    context 'when the user is NOT signed in' do

      it 'raises the error' do
        expect { helper.email_folders }.to raise_error
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
      before { 
        helper.sign_in(gmail_account.user)
      }

      it 'returns the gmail label' do
        expected = GmailLabel.where(:gmail_account => gmail_account)
        expect(helper.email_folders).to eq(expected)
      end
    end #__End of context "when the user is signed in"__

  end #__End of describe "#email_folders"__
end
