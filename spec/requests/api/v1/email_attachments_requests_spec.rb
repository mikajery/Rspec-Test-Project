require 'rails_helper'

describe Api::V1::EmailAttachmentsController, :type => :request do
  describe ".download" do
    context 'when the user is NOT signed in' do
      let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

      before do
        get "/api/v1/email_attachments/download/#{email_attachment.uid}"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      context "with no email_attachment of the email account" do
        let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

        it 'responds with the email attachment not found status code' do
          expected = $config.http_errors[:email_attachment_not_found][:status_code]
          get "/api/v1/email_attachments/download/#{email_attachment.uid}"
          expect(response.status).to eq(expected)  
        end

        it 'renders the email attachment not found error message' do
          expected = $config.http_errors[:email_attachment_not_found][:description]
          get "/api/v1/email_attachments/download/#{email_attachment.uid}"
          expect(response.body).to eq(expected)  
        end
      end #__End of context "with no email_attachment of the email account"__

      context "with email_attachments of the email account" do
        context "with no attachments_uploaded of the email_attachment email" do
          let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
          let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email) }
          
          it 'responds with the email attachment not ready status code' do
            expected = $config.http_errors[:email_attachment_not_ready][:status_code]
            get "/api/v1/email_attachments/download/#{email_attachment.uid}"
            expect(response.status).to eq(expected)  
          end

          it 'renders the email attachment not ready error message' do
            expected = $config.http_errors[:email_attachment_not_ready][:description]
            get "/api/v1/email_attachments/download/#{email_attachment.uid}"
            expect(response.body).to eq(expected)  
          end

          context "when the upload attachment delayed job does not exist" do

            it 'uploads the attachment' do
              expect_any_instance_of(Email).to receive(:delay).and_call_original

              get "/api/v1/email_attachments/download/#{email_attachment.uid}"
            end

            it 'saves the upload_attachments_delayed_job_id field of the email to the job id' do
              get "/api/v1/email_attachments/download/#{email_attachment.uid}"

              expect( email.reload.upload_attachments_delayed_job_id ).not_to be(nil)
            end
          end #__End of context "when the upload attachment delayed job does not exist"__
        end #__End of context "with no attachments_uploaded of the email_attachment email"__

        context "with attachments_uploaded of the email_attachment email" do
          let!(:email) { FactoryGirl.create(:email, email_account: gmail_account, attachments_uploaded: true) }
          let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email, s3_key: "s3-key") }

          it 'responds with 200 status code' do
            get "/api/v1/email_attachments/download/#{email_attachment.uid}"
            expect(response.status).to eq(200)  
          end

          it 'renders the s3 url' do
            expected = s3_url(email_attachment.s3_key)

            get "/api/v1/email_attachments/download/#{email_attachment.uid}"
            url = JSON.parse(response.body)["url"]

            expect( url ).to eq( expected )
          end
        end #__End of context "with no attachments_uploaded of the email_attachment email"__
      end #__End of context "with email_attachments of the email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".download"__
end
