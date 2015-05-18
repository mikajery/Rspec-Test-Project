require 'rails_helper'

describe 'api/v1/email_signatures/index', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'returns the email_signatures' do
    email_signatures = assign(:email_signatures, FactoryGirl.create_list(:email_signature, SpecMisc::MEDIUM_LIST_SIZE, :user => user))
    render
    email_signatures_rendered = JSON.parse(rendered)

    expected_attributes = %w(created_at uid name text html)

    expected_attributes_to_skip = %w(created_at)
    email_signatures.zip(email_signatures_rendered).each do |email_signature, email_signature_rendered|
      spec_validate_attributes(expected_attributes, email_signature, email_signature_rendered, expected_attributes_to_skip)
    end
  end
end
