class Api::V1::EmailTrackersController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_trackers, 'Email Trackers Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return email trackers.'

    response :ok
  end
  # :nocov:

  def index
    @email_trackers = @email_account.email_trackers.
                                     includes(:email_tracker_recipients => :email_tracker_views).
                                     order(:email_date => :desc)
  end
end
