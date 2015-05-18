require 'rails_helper'

describe Api::V1::SkinsController, :type => :request do

  context 'retrieving skins' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:skins) { FactoryGirl.create_list(:skin, SpecMisc::MEDIUM_LIST_SIZE) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing skins' do
      get '/api/v1/skins'
      skins_rendered = JSON.parse(response.body)
      
      expect(skins_rendered.length).to eq(skins.length)
      skins.zip(skins_rendered).each do |skin, skin_rendered|
        validate_skin(skin, skin_rendered)
      end
    end
  end

end
