class Api::V1::DelayedEmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :delayed_emails, 'Delayed Emails Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return delayed emails.'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def index
    @delayed_emails = @email_account.delayed_emails
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete delayed email.'

    param :path, :delayed_email_uid, :string, :required, 'Delayed Email UID'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def destroy
    delayed_email = @email_account.delayed_emails.find_by(:uid => params[:delayed_email_uid])
    delayed_email.destroy!() if delayed_email

    render :json => {}
  end
end
