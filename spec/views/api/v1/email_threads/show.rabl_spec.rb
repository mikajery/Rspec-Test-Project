require 'rails_helper'

describe 'api/v1/email_threads/show', :type => :view do
  it 'should render the email thread' do
    email_thread = assign(:email_thread, FactoryGirl.create(:email_thread))
    FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE, :email_thread => email_thread)

    render

    email_thread_rendered = JSON.parse(rendered)
    validate_email_thread(email_thread, email_thread_rendered)
  end
end
