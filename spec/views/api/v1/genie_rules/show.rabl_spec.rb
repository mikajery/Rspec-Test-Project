require 'rails_helper'

describe 'api/v1/genie_rules/show', :type => :view do
  it 'returns the genie rule' do
    genie_rule = assign(:genie_rule, FactoryGirl.create(:genie_rule))
    render
    genie_rule_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid from_address to_address subject list_id)
    spec_validate_attributes(expected_attributes, genie_rule, genie_rule_rendered)
  end
end
