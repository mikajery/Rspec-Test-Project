require 'rails_helper'

describe 'api/v1/genie_rules/index', :type => :view do
  it 'returns the email rule' do
    genie_rules = assign(:genie_rules, FactoryGirl.create_list(:genie_rule, SpecMisc::MEDIUM_LIST_SIZE))
    render
    genie_rules_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid from_address to_address subject list_id)
    
    genie_rules.zip(genie_rules_rendered).each do |genie_rule, genie_rule_rendered|
      spec_validate_attributes(expected_attributes, genie_rule, genie_rule_rendered)
    end
  end
end
