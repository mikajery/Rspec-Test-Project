require 'rails_helper'

describe 'api/v1/user_configurations/show', :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  
  it 'should render the user configuration' do
    user_configuration = assign(:user_configuration, user.user_configuration)

    render

    user_configuration_rendered = JSON.parse(rendered)

    expected_attributes = %w(id
                             auto_cleaner_enabled
                             demo_mode_enabled genie_enabled
                             skin_uid
                             email_signature_uid
                             split_pane_mode keyboard_shortcuts_enabled developer_enabled
                             installed_apps)
    
    expected_attributes_to_skip = %w(id installed_apps)
    spec_validate_attributes(expected_attributes, user_configuration, user_configuration_rendered, expected_attributes_to_skip)
  end
end
