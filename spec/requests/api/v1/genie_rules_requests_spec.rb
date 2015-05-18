require 'rails_helper'

describe Api::V1::GenieRulesController, :type => :request do
  context 'creating rules' do
    let!(:user) { FactoryGirl.create(:user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should create a rule' do
      post '/api/v1/genie_rules', :list_id => 'sales.turinginc.com', :destination_folder_name => 'sales'
      
      expect(response).to have_http_status(:ok)
      expect(user.genie_rules.count).to eq(1)
    end
  end
  
  context 'retrieving rules' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:genie_rules) { FactoryGirl.create_list(:genie_rule, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing rules' do
      get '/api/v1/genie_rules'
      genie_rules_rendered = JSON.parse(response.body)
      
      expect(genie_rules_rendered.length).to eq(genie_rules.length)
      genie_rules.zip(genie_rules_rendered).each do |genie_rule, genie_rule_rendered|
        validate_genie_rule(genie_rule, genie_rule_rendered)
      end
    end
  end
  
  context 'deleting rules' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:genie_rule) { FactoryGirl.create(:genie_rule, :user => user) }
    
    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }
      
      it 'should delete the rule' do
        expect(user.genie_rules.count).to eq(1)
        delete "/api/v1/genie_rules/#{genie_rule.uid}"
        expect(user.genie_rules.count).to eq(0)
      end
    end
    
    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT delete the rule' do
        expect(user.genie_rules.count).to eq(1)

        delete "/api/v1/genie_rules/#{genie_rule.uid}"
        expect(response).to have_http_status($config.http_errors[:genie_rule_not_found][:status_code])
        
        expect(user.genie_rules.count).to eq(1)
      end
    end
  end
end
