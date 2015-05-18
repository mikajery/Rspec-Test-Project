require 'rails_helper'

describe 'api/v1/ip_infos/show', :type => :view do
  it 'should render the user configuration' do
    ip_info = assign(:ip_info, FactoryGirl.create(:ip_info))

    render

    ip_info_rendered = JSON.parse(rendered)

    expected_attributes = %w(genie_enabled split_pane_mode)
    validate_ip_info(ip_info, ip_info_rendered)
  end
end
