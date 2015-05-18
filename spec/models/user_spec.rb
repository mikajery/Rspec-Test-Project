# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  admin                :boolean          default(FALSE)
#  email                :text
#  password_digest      :text
#  login_attempt_count  :integer          default(0)
#  has_genie_report_ran :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  profile_picture      :string(255)
#  name                 :string(255)
#  given_name           :string(255)
#  family_name          :string(255)
#

require 'rails_helper'

describe User, :type => :model do
  let(:user_template) { FactoryGirl.build(:user) }

  # relationship
  it { should have_one(:user_configuration).dependent(:destroy) }

  it { should have_many(:user_auth_keys).dependent(:destroy) }
  it { should have_many(:gmail_accounts).dependent(:destroy) }
  it { should have_many(:emails).through(:gmail_accounts) }
  it { should have_many(:email_threads).through(:gmail_accounts) }
  it { should have_many(:genie_rules).dependent(:destroy) }
  it { should have_many(:email_rules).dependent(:destroy) }
  it { should have_many(:apps).dependent(:destroy) }
  it { should have_many(:installed_apps).dependent(:destroy) }
  it { should have_many(:email_templates).dependent(:destroy) }
  it { should have_many(:email_signatures).dependent(:destroy) }
  it { should have_many(:email_attachment_uploads).dependent(:destroy) }

  # columns
  it { should have_db_column(:admin).of_type(:boolean)  }
  it { should have_db_column(:email).of_type(:text)  }
  it { should have_db_column(:password_digest).of_type(:text)  }
  it { should have_db_column(:login_attempt_count).of_type(:integer)  }
  it { should have_db_column(:has_genie_report_ran).of_type(:boolean)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index(:email).unique(true) }

  # validation callback
  describe ":before_validation" do
    context "when the email exists" do
      it "cleans the email before validation" do
        email = FFaker::Internet.email
        user = FactoryGirl.build(:user, email: email)

        user.valid?
        
        expect(user.email).to eq(cleanse_email(email))
      end
    end

    context "when the password_confirmation is nil" do
      it "sets the password_confirmation to the empty character before validation" do
        user = FactoryGirl.build(:user, password_confirmation: nil)

        user.valid?
        
        expect(user.password_confirmation).to eq('')
      end
    end
  end #__End of describe ":before_validation"__

  describe ":after_validation" do    
    it "deletes the password_digest from the error message after validation" do
      user = FactoryGirl.build(:user)

      errors = user.errors
      allow(user).to receive(:errors) { errors }

      messages = errors.messages
      allow(errors).to receive(:messages) { messages }

      allow(messages).to receive(:delete)

      user.valid?
    end
  
  end #__End of describe ":after_validation"__

  describe ":after_create" do  
    context "when the user_configuration is nil" do  
      it "sets the user_configuration after create" do
        user = FactoryGirl.create(:user, user_configuration: nil)

        expect(user.user_configuration.class).to eq(UserConfiguration)
      end
    end
  
  end #__End of describe ":after_create"__

  # class methods
  describe "#generate_email_verification_code" do
    it 'returns the string' do
      expect(User.generate_email_verification_code.class).to eq(String)
    end

    it 'returns the 16 length string' do
      expect(User.generate_email_verification_code.length).to eq(16)
    end
  end #__End of describe "#generate_email_verification_code"__

  describe "#get_update_params" do
    let(:params) {  ActionController::Parameters.new(
                      :user => { :email => user_template.email,
                                 :password => user_template.password,
                                 :password_confirmation => user_template.password}
                      ) }

    it 'returns the params' do
      expect( User.get_update_params(params).class ).to eq(ActionController::Parameters) 
    end

    context "when the include_password is true" do
      it 'pushes the :password and :password_confirmation to the permitted params' do
        expect( User.get_update_params(params, true).keys ).to eq( ["email", "password", "password_confirmation"] )
      end
    end
  end #__End of describe "#get_update_params"__

  describe "#get_unique_violation_error" do
    context 'when the email is in use' do
      it 'returns the email error message' do
        begin
          user_template.save
          user = FactoryGirl.build(:user, email: user_template.email)
          user.save
        rescue ActiveRecord::RecordNotUnique => unique_violation
          expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
        end
      end
    end

    context "when the another type of error raises" do
      it 'raises the error' do
        begin
          app_template = FactoryGirl.create(:app)
          app = FactoryGirl.build(:app, name: app_template.name)
          app.save
        rescue ActiveRecord::RecordNotUnique => unique_violation
          expect { User.get_unique_violation_error(unique_violation) }.to raise_error(unique_violation)
        end
      end
    end
  end #__End of describe "#get_unique_violation_error"__
  
  describe "#create_from_post" do
    let(:params) {  ActionController::Parameters.new(
                      :user => { :email => user_template.email,
                                 :password => user_template.password,
                                 :password_confirmation => user_template.password}
                      ) }

    context "when the email and password are valid" do
      it 'creates a new user' do 
        user, result = User.create_from_post(params)
        expect(result).to be(true)        
      end
    end

    context "when the the email is invalid" do
      it 'does not create a new user' do 
        params[:user][:email] = 'invalid email'
        user, result = User.create_from_post(params)
        expect(result).to eq(false)      
      end
    end

    context "when the email is in use" do
      it 'raises the error' do 
        user_template.save
        expect { User.create_from_post(params) }.to raise_error
      end
    end
  end #__End of describe "#create_from_post"__

  describe "#api_create" do
    
    context "when the email and password are valid" do
      it 'creates a new user' do 
        user, result = User.api_create(user_template.email, user_template.password)
        expect(result).to be(true)        
      end
    end

    context "when the the email is invalid" do
      it 'does not create a new user' do 
        user, result = User.api_create('invalid email', user_template.password)
        expect(result).to eq(false)      
      end
    end

    context "when the email is in use" do
      it 'raises the error' do 
        user_template.save
        expect { User.api_create(user_template.email, user_template.password) }.to raise_error
      end
    end
  end #__End of describe "#api_create"__

  describe "#cached_find" do
    let!(:user) { FactoryGirl.create(:user) }

    it 'returns the user by id' do
      expect( User.cached_find(user.id) ).to eq(user)
    end
  end #__End of describe "#api_create"__
    
  describe ".apply_email_rules" do
    let(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
    let(:email) { FactoryGirl.create(:email) }

    context "when the from_address of the email is same as the from_address of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, from_address: email.from_address, list_id: nil, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules([email])

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the from_address of the email ~"__

    context "when the list_id of the email is same as the list_id of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, list_id: email.list_id, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules([email])

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the subject of the email includes the subject of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, subject: email.subject, list_id: nil,  user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules([email])

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the to_address of the email_rule is not included in the email recipients" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, to_address: FFaker::Internet.email, user: user)
        end
      }

      it 'does not move any email to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules([email])

        expect(email_account).not_to have_received(:move_email_to_folder)
      end
    end #__End of context "when the to_address ~"__
    
  end #__End of describe ".apply_email_rules"__
  
  describe ".apply_email_rules_to_folder" do
    let!(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
    let!(:email) { FactoryGirl.create(:email) }

    context "when the from_address of the email is same as the from_address of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, from_address: email.from_address, list_id: nil, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        gmail_account = user.gmail_accounts.first
        folder = gmail_account.inbox_folder

        allow(user).to receive(:gmail_accounts) { [gmail_account] }

        allow(folder).to receive(:emails) { Email.all }      

        allow(gmail_account).to receive(:move_email_to_folder)

        gmail_account.user.apply_email_rules_to_folder(folder)

        expect(gmail_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the from_address of the email ~"__

    context "when the list_id of the email is same as the list_id of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, list_id: email.list_id, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        gmail_account = user.gmail_accounts.first
        folder = gmail_account.inbox_folder

        allow(user).to receive(:gmail_accounts) { [gmail_account] }

        allow(folder).to receive(:emails) { Email.all }      

        allow(gmail_account).to receive(:move_email_to_folder)

        gmail_account.user.apply_email_rules_to_folder(folder)

        expect(gmail_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the subject of the email includes the subject of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, subject: email.subject, list_id: nil,  user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        gmail_account = user.gmail_accounts.first
        folder = gmail_account.inbox_folder

        allow(user).to receive(:gmail_accounts) { [gmail_account] }

        allow(folder).to receive(:emails) { Email.all }      

        allow(gmail_account).to receive(:move_email_to_folder)

        gmail_account.user.apply_email_rules_to_folder(folder)

        expect(gmail_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the to_address of the email_rule is included in the email recipients" do
      before(:each) {
        email_recipient = FactoryGirl.create(:email_recipient, email: email)

        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, to_address: email_recipient.person.email_address, list_id: nil, user: user)
        end
      }

      it 'does not move any email to the destination folder of the email_rule' do        
        gmail_account = user.gmail_accounts.first
        folder = gmail_account.inbox_folder

        allow(user).to receive(:gmail_accounts) { [gmail_account] }

        allow(folder).to receive(:emails) { Email.all }      

        allow(gmail_account).to receive(:move_email_to_folder)

        gmail_account.user.apply_email_rules_to_folder(folder)

        expect(gmail_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the to_address ~"__

  end #__End of describe ".apply_email_rules_to_folder"__
  
  
  describe ".apply_email_rules_to_email" do
    let!(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
    let!(:email) { FactoryGirl.create(:email) }

    context "when the from_address of the email is same as the from_address of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, from_address: email.from_address, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules_to_email(email)

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the from_address of the email ~"__

    context "when the list_id of the email is same as the list_id of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, list_id: email.list_id, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules_to_email(email)

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the subject of the email includes the subject of the email_rule" do
      before(:each) {
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, subject: email.subject, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules_to_email(email)

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__

    context "when the to_address of the email_rule matches the email_address of the email_recipient" do
      before(:each) {
        email_recipient = FactoryGirl.create(:email_recipient, email: email)
        
        2.times do
          # email rules of the user
          FactoryGirl.create(:email_rule, to_address: email_recipient.person.email_address, list_id: nil, user: user)
        end
      }

      it 'moves the emails to the destination folder of the email_rule' do        
        email_account = user.gmail_accounts.first

        allow(user).to receive(:gmail_accounts) { [email_account] }

        allow(email_account).to receive(:move_email_to_folder)

        user.apply_email_rules_to_email(email)

        expect(email_account).to have_received(:move_email_to_folder).twice
      end
    end #__End of context "when the list_id of the email ~"__
  end #__End of describe ".apply_email_rules_to_email"__

  describe '#destroy' do
    let!(:user) { FactoryGirl.create(:user) }

    let!(:user_auth_keys) { FactoryGirl.create_list(:user_auth_key, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:email_accounts) { FactoryGirl.create_list(:gmail_account, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:genie_rules) { FactoryGirl.create_list(:genie_rule, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:email_rules) { FactoryGirl.create_list(:email_rule, SpecMisc::SMALL_LIST_SIZE, :user => user) }

    it 'should destroy the associated models' do
      expect(UserAuthKey.where(:user => user).count).to eq(user_auth_keys.length)
      expect(GmailAccount.where(:user => user).count).to eq(email_accounts.length)
      expect(GenieRule.where(:user => user).count).to eq(genie_rules.length)
      expect(EmailRule.where(:user => user).count).to eq(email_rules.length)
      
      expect(UserConfiguration.where(:user => user).count).to eq(1)

      expect(user.destroy).not_to be(false)

      expect(UserAuthKey.where(:user => user).count).to eq(0)
      expect(GmailAccount.where(:user => user).count).to eq(0)
      expect(GenieRule.where(:user => user).count).to eq(0)
      expect(EmailRule.where(:user => user).count).to eq(0)
      
      expect(UserConfiguration.where(:user => user).count).to eq(0)
    end
  end
end
