# == Schema Information
#
# Table name: user_auth_keys
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  encrypted_auth_key :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

describe UserAuthKey, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  # relationship
  it { should belong_to :user }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:encrypted_auth_key).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }

  # indexes
  it { should have_db_index(:encrypted_auth_key) }
  it { should have_db_index(:user_id) }

  # validation
  it { should validate_presence_of(:user) }
  it "populates the encrypted_auth_key before validation" do

    user_auth_key = FactoryGirl.build(:user_auth_key, user: user, encrypted_auth_key: nil)

    user_auth_key.valid?

    expect(user_auth_key.encrypted_auth_key.present?).to be(true)
  end

  it "deletes the cache after commit" do
    user_auth_key = FactoryGirl.build(:user_auth_key, user: user)
    expect(Rails.cache).to receive(:delete)
    user_auth_key.save
  end

  # methods
  describe "#secure_hash" do
    let(:data) { "input data" }

    it 'returns the secure hash' do

      allow(Digest::SHA1).to receive(:hexdigest).with(data).and_call_original

      UserAuthKey.secure_hash(data)
    end
  end #__End of describe "#secure_hash"__

  describe "#new_key" do

    it 'returns the new key' do

      allow(SecureRandom).to receive(:urlsafe_base64).and_call_original

      UserAuthKey.new_key
    end
  end #__End of describe "#new_key"__

  describe ".cached_find_by_encrypted_auth_key" do
    let!(:user_auth_key) { FactoryGirl.create(:user_auth_key, user: user) }

    it 'fetches the user auth key by encrypted_auth_key' do
      expect( UserAuthKey.cached_find_by_encrypted_auth_key(user_auth_key.encrypted_auth_key) ).to eq( user_auth_key )
    end
  end #__End of describe "#new_key"__
end
