module GmailAccountsHelper
  def gmail_o_auth2_url(force = false)
    o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)

    o_auth2_base_client.redirect_uri = gmail_oauth2_callback_url
    o_auth2_base_client.scope = GmailAccount::SCOPES

    options = {}
    options[:access_type] = :offline
    options[:approval_prompt] = force ? :force : :auto
    options[:include_granted_scopes] = true

    url = o_auth2_base_client.authorization_uri(options).to_s()
    return url
  end
end
