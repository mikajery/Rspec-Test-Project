require 'rails_helper'

describe Api::V1::EmailRulesController, :type => :request do
  context 'creating rules' do
    let!(:user) { FactoryGirl.create(:user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should create a rule' do
      post '/api/v1/email_rules', :list_id => 'sales.turinginc.com', :destination_folder_name => 'sales'
      
      expect(response).to have_http_status(:ok)
      expect(user.email_rules.count).to eq(1)
    end
  end
  
  context 'retrieving rules' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_rules) { FactoryGirl.create_list(:email_rule, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing rules' do
      get '/api/v1/email_rules'
      email_rules_rendered = JSON.parse(response.body)
      
      expect(email_rules_rendered.length).to eq(email_rules.length)
      email_rules.zip(email_rules_rendered).each do |email_rule, email_rule_rendered|
        validate_email_rule(email_rule, email_rule_rendered)
      end
    end
  end
  
  context 'recommended rules' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE,
                                            :email_account => gmail_account,
                                            :list_id => 'test.list.com',
                                            :auto_filed => true ) }
    
    let!(:emails_other) { FactoryGirl.create_list(:email, $config.recommended_rules_average_daily_list_volume - 1,
                                                  :email_account => gmail_account,
                                                  :list_id => 'test2.list.com',
                                                  :auto_filed => true ) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    it 'should recommend rules' do
      get '/api/v1/email_rules/recommended_rules'
      json = JSON.parse(response.body)
      expect(json.keys).to eq(["rules_recommended"])

      rules_recommended = json["rules_recommended"]
      expect(rules_recommended.length).to eq(1)
      expect(rules_recommended[0]['list_id']).to eq('test.list.com')
      expect(rules_recommended[0]['destination_folder_name']).to eq("List Emails/test.list.com")
    end
  end

  context 'deleting rules' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_rule) { FactoryGirl.create(:email_rule, :user => user) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'should delete the rule' do
        expect(user.email_rules.count).to eq(1)
        delete "/api/v1/email_rules/#{email_rule.uid}"
        expect(user.email_rules.count).to eq(0)
      end
    end

    context 'when the other user is signed in' do
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      it 'should NOT delete the rule' do
        expect(user.email_rules.count).to eq(1)
        
        delete "/api/v1/email_rules/#{email_rule.uid}"
        expect(response).to have_http_status($config.http_errors[:email_rule_not_found][:status_code])
        
        expect(user.email_rules.count).to eq(1)
      end
    end
  end
end
