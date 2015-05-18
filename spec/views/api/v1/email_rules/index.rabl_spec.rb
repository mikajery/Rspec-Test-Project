require 'rails_helper'

describe 'api/v1/email_rules/index', :type => :view do
  it 'returns the email rule' do
    email_rules = assign(:email_rules, FactoryGirl.create_list(:email_rule, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_rules_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             from_address to_address subject
                             list_id destination_folder_name)
    
    email_rules.zip(email_rules_rendered).each do |email_rule, email_rule_rendered|
      spec_validate_attributes(expected_attributes, email_rule, email_rule_rendered)
    end
  end
end
