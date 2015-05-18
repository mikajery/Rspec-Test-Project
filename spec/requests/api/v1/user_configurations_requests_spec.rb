require 'rails_helper'

describe Api::V1::UserConfigurationsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_configuration) { user.user_configuration }
  before { post '/api/v1/sessions', :email => user.email, :password => user.password }
  
  it 'updates the user configuration' do
    expect(user_configuration.genie_enabled).to be(true)
    expect(user_configuration.split_pane_mode).to eq(UserConfiguration.split_pane_modes[:horizontal])
    
    patch '/api/v1/user_configurations', :genie_enabled => false,
          :split_pane_mode => UserConfiguration.split_pane_modes[:off]
    expect(response).to have_http_status(:ok)
    
    user_configuration.reload
    expect(user_configuration.genie_enabled).to be(false)
    expect(user_configuration.split_pane_mode).to eq(UserConfiguration.split_pane_modes[:off])

    patch '/api/v1/user_configurations', :genie_enabled => true,
          :split_pane_mode => UserConfiguration.split_pane_modes[:vertical]
    expect(response).to have_http_status(:ok)

    user_configuration.reload
    expect(user_configuration.genie_enabled).to be(true)
    expect(user_configuration.split_pane_mode).to eq(UserConfiguration.split_pane_modes[:vertical])

    patch '/api/v1/user_configurations', :genie_enabled => false,
          :split_pane_mode => UserConfiguration.split_pane_modes[:off]
    expect(response).to have_http_status(:ok)
    
    user_configuration.reload
    expect(user_configuration.genie_enabled).to be(false)
    expect(user_configuration.split_pane_mode).to eq(UserConfiguration.split_pane_modes[:off])
  end
  
  it 'returns the user configuration' do
    get '/api/v1/user_configurations'
    
    expect(response).to have_http_status(:ok)
    expect(response).to render_template('api/v1/user_configurations/show')
  end
end