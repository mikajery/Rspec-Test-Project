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

class UserAuthKey < ActiveRecord::Base
  belongs_to :user

  validates :user, :encrypted_auth_key, presence: true

  before_validation {
    self.encrypted_auth_key = UserAuthKey.secure_hash(UserAuthKey.new_key) if self.encrypted_auth_key.nil?
  }

  after_commit {
    Rails.cache.delete([self.class.name, encrypted_auth_key])
  }

  def UserAuthKey.secure_hash(data)
    return Digest::SHA1.hexdigest(data)
  end

  def UserAuthKey.new_key
    return SecureRandom.urlsafe_base64
  end

  def self.cached_find_by_encrypted_auth_key(encrypted_auth_key)
    Rails.cache.fetch([name, encrypted_auth_key]) { find_by_encrypted_auth_key(encrypted_auth_key) }
  end
end
