require 'rails_helper'

describe 'api/v1/emails/index', :type => :view do
  it 'returns the emails' do
    emails = assign(:emails, FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE))
    render
    emails_rendered = JSON.parse(rendered)

    emails.zip(emails_rendered).each do |email, email_rendered|
      validate_email(email, email_rendered)
    end
  end
end
