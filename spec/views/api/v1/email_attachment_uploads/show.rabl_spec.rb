require 'rails_helper'

describe 'api/v1/email_attachment_uploads/show', :type => :view do
  it 'should render a email_attachment_upload' do
    email_attachment_upload = assign(:email_attachment_upload, FactoryGirl.create(:email_attachment_upload))

    render

    email_attachment_upload_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             filename
                             s3_key
                             s3_key_full)

    spec_validate_attributes(expected_attributes, email_attachment_upload, email_attachment_upload_rendered)
  end
end
