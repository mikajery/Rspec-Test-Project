require 'signet/oauth_2/client'

module Google
  class OAuth2Client
    def OAuth2Client.base_client(client_id, client_secret)
      o_auth2_base_client = Signet::OAuth2::Client.new()

      o_auth2_base_client.client_id = client_id
      o_auth2_base_client.client_secret = client_secret

      o_auth2_base_client.authorization_uri = 'https://accounts.google.com/o/oauth2/auth'
      o_auth2_base_client.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'

      return o_auth2_base_client
    end

    attr_accessor :api_client, :o_auth2_api

    def initialize(api_client)
      self.api_client = api_client
      self.o_auth2_api = api_client.discovered_api('oauth2', 'v2')
    end

    def tokeninfo(access_token)
      args = method(__method__).parameters.map { |arg| {arg[1] => eval(arg[1].to_s)} }
      parameters = Google::Misc.get_parameters_from_args(args)

      result = self.api_client.execute!(:api_method => self.o_auth2_api.tokeninfo,
                                        :parameters => parameters)
      return result.data
    end

    def userinfo_get()
      result = self.api_client.execute!(:api_method => self.o_auth2_api.userinfo.get)
      return result.data
    end
  end
end
