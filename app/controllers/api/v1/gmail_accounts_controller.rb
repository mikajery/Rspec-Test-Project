class Api::V1::GmailAccountsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :gmail_accounts, 'Gmail Accounts Controller'

  # :nocov:
  swagger_api :get_token do
    summary 'Return the Gmail OAuth2 token.'

    response :ok
  end
  # :nocov:

  def get_token
    @google_o_auth2_token = @email_account.google_o_auth2_token
    @google_o_auth2_token.refresh()
    render 'api/v1/google_o_auth_2_tokens/show'
  end
end
