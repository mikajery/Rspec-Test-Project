class Api::V1::EmailAccountsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_accounts, 'Email Accounts Controller'

  # :nocov:
  swagger_api :send_email do
    summary 'Send an email.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :tracking_enabled, :boolean, false, 'Tracking Enabled'

    param :form, :bounce_back_enabled, :boolean, false, 'Bounce Back Enabled'
    param :form, :bounce_back_time, :string, false, 'Bounce Back Time'
    param :form, :bounce_back_type, :string, false, 'Bounce Back Type'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def send_email
    @email_account.delay.send_email(params[:tos], params[:ccs], params[:bccs],
                                    params[:subject], params[:html_part], params[:text_part],
                                    params[:email_in_reply_to_uid],
                                    params[:tracking_enabled].downcase == 'true',
                                    params[:bounce_back_enabled].downcase == 'true', params[:bounce_back_time], params[:bounce_back_type],
                                    params[:attachment_s3_keys])
    render :json => {}
  end

  # :nocov:
  swagger_api :send_email_delayed do
    summary 'Send email delayed.'

    param :form, :sendAtDateTime, :string, false, 'Datetime to send the email'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :tracking_enabled, :boolean, false, 'Tracking Enabled'

    param :form, :bounce_back_enabled, :boolean, false, 'Bounce Back Enabled'
    param :form, :bounce_back_time, :string, false, 'Bounce Back Time'
    param :form, :bounce_back_type, :string, false, 'Bounce Back Type'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def send_email_delayed
    @email_account.with_lock do
      delayed_email = DelayedEmail.new
      delayed_email.email_account = @email_account

      delayed_email.tos = params[:tos]
      delayed_email.ccs = params[:ccs]
      delayed_email.bccs = params[:bccs]

      delayed_email.subject = params[:subject]

      delayed_email.html_part = params[:html_part]
      delayed_email.text_part = params[:text_part]

      delayed_email.email_in_reply_to_uid = params[:email_in_reply_to_uid]

      delayed_email.tracking_enabled = params[:tracking_enabled]

      delayed_email.bounce_back = params[:bounce_back_enabled].downcase == 'true'
      delayed_email.bounce_back_time = params[:bounce_back_time]
      delayed_email.bounce_back_type = params[:bounce_back_type]

      delayed_email.attachment_s3_keys = params[:attachment_s3_keys]

      delayed_email.save!

      delayed_job = delayed_email.delay({:run_at => params[:sendAtDateTime]}, heroku_scale: false).send_and_destroy()
      delayed_email.delayed_job_id = delayed_job.id
      delayed_email.save!

      @delayed_email = delayed_email
    end

    @email_account.delete_draft(params[:draft_id]) if params[:draft_id]

    render "api/v1/delayed_emails/show"
  end

  # :nocov:
  swagger_api :sync do
    summary 'Queues email sync.'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def sync
    @email_account.queue_sync_account()

    render :json => @email_account.last_sync_at
  end

  # :nocov:
  swagger_api :search_threads do
    summary 'Search email threads using the same query format as the Gmail search box.'

    param :form, :query, :string, :required, 'Query - same query format as the Gmail search box.'
    param :form, :next_page_token, :string, false, 'Next Page Token - returned in a prior search_threads call.'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def search_threads
    email_thread_uids, @next_page_token = @email_account.search_threads(params[:query], params[:next_page_token])
    @email_threads = EmailThread.where(:uid => email_thread_uids).joins(:emails).includes(:emails).order('"emails"."date" DESC')
  end

  # :nocov:
  swagger_api :create_draft do
    summary 'Create email draft.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def create_draft
    @email = @email_account.create_draft(params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part],
                                         params[:email_in_reply_to_uid],
                                         params[:attachment_s3_keys])
    render 'api/v1/emails/show'
  end

  # :nocov:
  swagger_api :update_draft do
    summary 'Update email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def update_draft
    @email = @email_account.update_draft(params[:draft_id],
                                         params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part],
                                         params[:attachment_s3_keys])
    render 'api/v1/emails/show'
  end

  # :nocov:
  swagger_api :send_draft do
    summary 'Send email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def send_draft
    @email = @email_account.send_draft(params[:draft_id])

    render 'api/v1/emails/show'
  end

  # :nocov:
  swagger_api :delete_draft do
    summary 'Delete email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def delete_draft
    @email_account.delete_draft(params[:draft_id])

    render :json => {}
  end

  # :nocov:
  swagger_api :cleaner_report do
    summary 'Cleaner report.'

    response :ok
  end
  # :nocov:

  def cleaner_report
    inbox_label = @email_account.inbox_folder
    if inbox_label
      # Need to put a counter cache here.
      @num_important_emails = @important_emails = inbox_label.emails.where('auto_file_folder_name IS NULL').count()
      @important_emails = inbox_label.emails.where('auto_file_folder_name IS NULL').
                                             includes([:email_attachments, :email_attachment_uploads, :gmail_labels]).
                                             order(:date => :desc).limit(100)
    else
      @num_important_emails = 0
      @important_emails = []
    end

    @num_auto_filed_emails = @email_account.emails.where(:queued_auto_file => false).
                                                   where('auto_file_folder_name IS NOT NULL').count()

    @auto_filed_emails = @email_account.emails.where(:queued_auto_file => false).
                                               where('auto_file_folder_name IS NOT NULL').
                                               order(:date => :desc).limit(100)
  end

  # :nocov:
  swagger_api :apply_cleaner do
    summary 'Apply cleaner.'

    response :ok
  end
  # :nocov:

  def apply_cleaner
    @email_account.emails.where('auto_file_folder_name IS NOT NULL').update_all(:queued_auto_file => true)
    @email_account.delay.apply_cleaner()

    render :json => {}
  end
end