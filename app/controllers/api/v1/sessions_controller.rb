class Api::V1::SessionsController < ApiController
  swagger_controller :sessions, 'Session Management'

  # :nocov:
  swagger_api :create do
    summary 'Login'
    notes 'Logs the user in and sets a session cookie'

    param :form, :email, :string, :required, 'Email'
    param :form, :password, :string, :required, 'Password'

    response :unauthorized
    response $config.http_errors[:account_locked][:status_code], $config.http_errors[:account_locked][:description]
  end
  # :nocov:

  def create
    user_signin_attempt(params[:email], params[:password], true)
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Logout'
  end
  # :nocov:

  def destroy
    sign_out
    render :json => {}
  end
end
