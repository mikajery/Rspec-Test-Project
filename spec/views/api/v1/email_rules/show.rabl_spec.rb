require 'rails_helper'

describe 'api/v1/email_rules/show', :type => :view do
  it 'returns the email rule' do
    email_rule = assign(:email_rule, FactoryGirl.create(:email_rule))
    render
    email_rule_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             from_address to_address subject
                             list_id destination_folder_name)
    spec_validate_attributes(expected_attributes, email_rule, email_rule_rendered)
  end
end
