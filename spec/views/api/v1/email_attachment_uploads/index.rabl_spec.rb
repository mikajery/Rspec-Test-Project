require 'rails_helper'

describe 'api/v1/email_attachment_uploads/index', :type => :view do
  it 'returns the email_attachment_uploads' do
    email_attachment_uploads = assign(:email_attachment_uploads, FactoryGirl.create_list(:email_attachment_upload, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_attachment_uploads_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid filename s3_key s3_key_full)

    email_attachment_uploads.zip(email_attachment_uploads_rendered).each do |email_attachment_upload, email_attachment_upload_rendered|
      spec_validate_attributes(expected_attributes, email_attachment_upload, email_attachment_upload_rendered)
    end
  end
end
