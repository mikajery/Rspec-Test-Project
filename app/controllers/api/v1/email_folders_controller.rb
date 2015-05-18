class Api::V1::EmailFoldersController < ApiController
  before_action do
    signed_in_user(true)
  end

  swagger_controller :email_folders, 'Email Folders Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return folders in current account.'

    response :ok
  end
  # :nocov:

  def index
    @gmail_labels = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first)
    
    render 'api/v1/gmail_labels/index'
  end
end
