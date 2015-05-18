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

class GoogleOAuth2Token < ActiveRecord::Base
  belongs_to :google_api, polymorphic: true

  validates :google_api, :access_token, :expires_in, :issued_at, :refresh_token, :expires_at, presence: true

  before_destroy {
    log_console('DESTROYING GoogleOAuth2Token!!')
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.refresh_token}") if self.refresh_token != 'factory' }
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.access_token}") if self.access_token != 'factory' }
  }

  def o_auth2_base_client()
    o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)

    o_auth2_base_client.access_token = self.access_token
    o_auth2_base_client.expires_in = self.expires_in
    o_auth2_base_client.issued_at = Time.at(self.issued_at)
    o_auth2_base_client.refresh_token = self.refresh_token

    self.refresh(o_auth2_base_client)

    return o_auth2_base_client
  end

  def api_client()
    o_auth2_base_client = self.o_auth2_base_client()

    api_client = Google::APIClient.new(:application_name => $config.service_name)
    api_client.authorization = o_auth2_base_client

    return api_client
  end

  def refresh(o_auth2_base_client = nil, force = false)
    # guard against simultaneous refreshes

    self.with_lock do
      return if self.expires_at - Time.now >= 60.seconds && !force
      
      log_console('REFRESHING TOKEN')
      self.log()

      o_auth2_base_client = self.o_auth2_base_client() if o_auth2_base_client.nil?
      o_auth2_base_client.fetch_access_token!()
      self.update(o_auth2_base_client)

      log_console('TOKEN REFRESHED!')
      self.log()
    end
  end

  def update(o_auth2_base_client, do_save = true)
    log_console('UPDATING TOKEN')
    self.log()

    self.access_token = o_auth2_base_client.access_token
    self.expires_in = o_auth2_base_client.expires_in
    self.issued_at = o_auth2_base_client.issued_at
    self.refresh_token = o_auth2_base_client.refresh_token if !o_auth2_base_client.refresh_token.blank?

    self.expires_at = Time.at(self.issued_at).to_datetime + self.expires_in.seconds

    self.save! if do_save

    log_console('TOKEN UPDATED')
    self.log()
  end

  def log()
=begin
    log_console("access_token=#{self.access_token}\n" +
                "expires_in=#{self.expires_in}\n" +
                "issued_at=#{self.issued_at}\n" +
                "refresh_token=#{self.refresh_token}\n")
=end
  end
end
