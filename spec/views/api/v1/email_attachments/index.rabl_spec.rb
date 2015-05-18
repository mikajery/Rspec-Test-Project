require 'rails_helper'

describe 'api/v1/email_attachments/index', :type => :view do
  it 'returns the email_attachments' do
    email_attachments = assign(:email_attachments, FactoryGirl.create_list(:email_attachment, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_attachments_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid filename)

    email_attachments.zip(email_attachments_rendered).each do |email_attachment, email_attachment_rendered|
      spec_validate_attributes(expected_attributes, email_attachment, email_attachment_rendered)
    end
  end
end
