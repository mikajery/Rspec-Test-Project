require 'rails_helper'

describe 'api/v1/emails/show', :type => :view do
  it 'should render the email' do
    email = assign(:email, FactoryGirl.create(:email))
    render
    email_rendered = JSON.parse(rendered)

    validate_email(email, email_rendered)
  end
end
