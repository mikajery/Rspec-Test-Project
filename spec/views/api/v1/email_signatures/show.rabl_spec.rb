require 'rails_helper'

describe 'api/v1/email_signatures/show', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'should render a email_signature' do
    email_signature = assign(:email_signature, FactoryGirl.create(:email_signature, :user => user))


    render

    email_signature_rendered = JSON.parse(rendered)

    expected_attributes = %w(created_at
                             uid
                             name
                             text
                             html)

    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_signature, email_signature_rendered, expected_attributes_to_skip)
  end
end
