# == Schema Information
#
# Table name: google_o_auth2_tokens
#
#  id              :integer          not null, primary key
#  google_api_id   :integer
#  google_api_type :string(255)
#  access_token    :text
#  expires_in      :integer
#  issued_at       :integer
#  refresh_token   :text
#  expires_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

describe GoogleOAuth2Token, :type => :model do
  let(:gmail_account) { FactoryGirl.create(:gmail_account) }

  # relationship
  it { should belong_to :google_api }

  # columns
  it { should have_db_column(:google_api_id).of_type(:integer)  }
  it { should have_db_column(:google_api_type).of_type(:string)  }
  it { should have_db_column(:access_token).of_type(:text)  }
  it { should have_db_column(:expires_in).of_type(:integer)  }
  it { should have_db_column(:issued_at).of_type(:integer)  }
  it { should have_db_column(:refresh_token).of_type(:text)  }
  it { should have_db_column(:expires_at).of_type(:datetime)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index([:google_api_id, :google_api_type]) }

  # validation
  it { should validate_presence_of(:google_api) }
  it { should validate_presence_of(:access_token) }
  it { should validate_presence_of(:expires_in) }
  it { should validate_presence_of(:issued_at) }
  it { should validate_presence_of(:refresh_token) }
  it { should validate_presence_of(:expires_at) }

  # callback
  describe "before_destroy" do

    context 'when the refresh token is not "factory"' do
      it 'revokes the google account with the refresh token' do
        google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, refresh_token: "not factory")
        RestClient.should_receive(:get).with("https://accounts.google.com/o/oauth2/revoke?token=#{google_o_auth2_token.refresh_token}")
        google_o_auth2_token.destroy
      end
    end

    context 'when the access token is not "factory"' do
      it 'revokes the google account with the access token' do
        google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, access_token: "not factory")
        RestClient.should_receive(:get).with("https://accounts.google.com/o/oauth2/revoke?token=#{google_o_auth2_token.access_token}")
        google_o_auth2_token.destroy
      end
    end
  end #__End of describe "before_destroy"__

  # methods
  describe ".o_auth2_base_client" do
    let(:google_o_auth2_token) { FactoryGirl.create(:google_o_auth2_token) }

    it 'returns the google auth2 base client' do      
      expect(google_o_auth2_token.o_auth2_base_client.class).to eq(Signet::OAuth2::Client)
    end

    it 'returns the google auth2 base client with the access_token' do      
      expect(google_o_auth2_token.o_auth2_base_client.access_token).to eq(google_o_auth2_token.access_token)
    end

    it 'returns the google auth2 base client with the expires_in' do      
      expect(google_o_auth2_token.o_auth2_base_client.expires_in).to eq(google_o_auth2_token.expires_in)
    end

    it 'returns the google auth2 base client with the issued_at' do      
      expect(google_o_auth2_token.o_auth2_base_client.issued_at).to eq(Time.at(google_o_auth2_token.issued_at))
    end

    it 'returns the google auth2 base client with the refresh_token' do      
      expect(google_o_auth2_token.o_auth2_base_client.refresh_token).to eq(google_o_auth2_token.refresh_token)
    end
  end #__End of describe ".o_auth2_base_client"__

  describe ".api_client" do
    let(:google_o_auth2_token) { FactoryGirl.create(:google_o_auth2_token) }

    it 'returns the google api client' do      
      expect(google_o_auth2_token.api_client.class).to eq(Google::APIClient)
    end

    it 'returns the google api client with the google auth2 base client as the authorization' do      
      expect(google_o_auth2_token.api_client.authorization.class).to eq(Signet::OAuth2::Client)
    end    

  end #__End of describe ".api_client"__    

  describe ".refresh" do

    context 'when the expires_at is greater 60 seconds than now and the force is false' do
      it 'does nothing' do
        google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, expires_at: (DateTime.now + 70.seconds).rfc2822)

        google_o_auth2_token.should_not_receive(:update)
        google_o_auth2_token.refresh(nil, false)
      end
    end

    context 'when the expires_at is smaller 60 seconds than now' do
      before(:all) do
        @google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, expires_at: (DateTime.now + 10.seconds).rfc2822)

        @o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)
        @o_auth2_base_client.access_token = @google_o_auth2_token.access_token
        @o_auth2_base_client.expires_in = @google_o_auth2_token.expires_in
        @o_auth2_base_client.issued_at = Time.at(@google_o_auth2_token.issued_at)
        @o_auth2_base_client.refresh_token = @google_o_auth2_token.refresh_token
      end

      it 'fetches the access token' do

        allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }

        @google_o_auth2_token.refresh(@o_auth2_base_client)
      end

      it 'updates itself with the google auth2 base client' do

        allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }
        allow(@google_o_auth2_token).to receive(:update) { true }

        @google_o_auth2_token.refresh(@o_auth2_base_client)
      end
    end #__End of context 'when the expires_at is smaller 60 seconds than now'__   

    context 'when the force is true' do
      before(:all) do
        @google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token)

        @o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)
        @o_auth2_base_client.access_token = @google_o_auth2_token.access_token
        @o_auth2_base_client.expires_in = @google_o_auth2_token.expires_in
        @o_auth2_base_client.issued_at = Time.at(@google_o_auth2_token.issued_at)
        @o_auth2_base_client.refresh_token = @google_o_auth2_token.refresh_token
      end

      it 'fetches the access token' do

        allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }

        @google_o_auth2_token.refresh(@o_auth2_base_client, true)
      end

      it 'updates itself with the google auth2 base client' do

        allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }
        allow(@google_o_auth2_token).to receive(:update) { true }

        @google_o_auth2_token.refresh(@o_auth2_base_client, true)
      end
    end #__End of context 'when the force is true'__  
  end #__End of describe ".refresh"__   

  describe ".update" do
    let(:google_o_auth2_token1) { FactoryGirl.create(:google_o_auth2_token) }
    let(:google_o_auth2_token2) { FactoryGirl.create(:google_o_auth2_token) }

    context 'when the do_save is true' do
      let(:o_auth2_base_client) { google_o_auth2_token1.o_auth2_base_client }
      
      before(:each) do
        google_o_auth2_token2.update(o_auth2_base_client, true)
      end

      it 'updates the access_token with the one of the google auth2 base client' do

        expect(google_o_auth2_token2.reload.access_token).to eq(o_auth2_base_client.access_token)
      end

      it 'updates the expires_in with the one of the google auth2 base client' do

        expect(google_o_auth2_token2.reload.expires_in).to eq(o_auth2_base_client.expires_in)
      end

      it 'updates the issued_at with the one of the google auth2 base client' do
        
        expect(Time.at(google_o_auth2_token2.reload.issued_at)).to eq(o_auth2_base_client.issued_at)
      end

      it 'updates the refresh_token with the one of the google auth2 base client' do
        
        expect(google_o_auth2_token2.reload.refresh_token).to eq(o_auth2_base_client.refresh_token)
      end

      it 'updates the expires_at with the one of the google auth2 base client' do
        
        expect(google_o_auth2_token2.reload.expires_at).to eq(o_auth2_base_client.expires_at)
      end
    end
  end #__End of describe ".update"__ 

  describe ".log" do
    let(:google_o_auth2_token) { FactoryGirl.create(:google_o_auth2_token) }

    it 'calls the log method' do
      
      allow(google_o_auth2_token).to receive(:log).and_call_original

      google_o_auth2_token.log
    end
  end #__End of describe ".log"__      

end
