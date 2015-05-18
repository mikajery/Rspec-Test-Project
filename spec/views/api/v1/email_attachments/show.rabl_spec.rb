require 'rails_helper'

describe 'api/v1/email_attachments/show', :type => :view do
  it 'should render a email_attachment' do
    email_attachment = assign(:email_attachment, FactoryGirl.create(:email_attachment))

    render

    email_attachment_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             filename)

    spec_validate_attributes(expected_attributes, email_attachment, email_attachment_rendered)
  end
end
