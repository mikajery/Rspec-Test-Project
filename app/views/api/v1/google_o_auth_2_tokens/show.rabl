object @google_o_auth2_token

attributes :access_token

node(:expires_in) do |google_o_auth2_token|
  (google_o_auth2_token.expires_at - DateTime.now).to_i
end

node(:state) do
  GmailAccount::SCOPES.join(' ')
end
