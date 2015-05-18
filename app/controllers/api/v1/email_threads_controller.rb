class Api::V1::EmailThreadsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:inbox, :in_folder, :retrieve, :move_to_folder, :apply_gmail_label,:remove_from_folder, :trash, :snooze]
  before_action :correct_email_account
  before_action :filter_email_thread_uids, :only => [:move_to_folder, :apply_gmail_label, :remove_from_folder, :trash, :snooze]

  swagger_controller :email_threads, 'Email Threads Controller'

  # :nocov:
  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    param :query, :last_email_thread_uid, :string, :required, 'Last Email Thread UID'
    param :query, :dir, :string, :required, 'Query Direction'

    response :ok
  end
  # :nocov:

  def inbox
    inbox_label = @email_account.inbox_folder
    last_email_thread = EmailThread.find_by(:email_account => @email_account,
                                            :uid => params[:last_email_thread_uid])

    if inbox_label.nil?
      @email_threads = []
    else
      @email_threads = inbox_label.get_sorted_paginated_threads(last_email_thread: last_email_thread, dir: params[:dir], threads_per_page: 30)
    end

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :in_folder do
    summary 'Return email threads in folder.'

    param :query, :folder_id, :string, :required, 'Email Folder ID'
    param :query, :last_email_thread_uid, :string, :required, 'Last Email Thread UID'
    param :query, :dir, :string, :required, 'Query Direction'

    response :ok
    response $config.http_errors[:email_folder_not_found][:status_code],
             $config.http_errors[:email_folder_not_found][:description]
  end
  # :nocov:

  def in_folder
    email_folder = GmailLabel.find_by(:gmail_account => @email_account,
                                       :label_id => params[:folder_id])
    last_email_thread = EmailThread.find_by(:email_account => @email_account,
                                            :uid => params[:last_email_thread_uid])

    if email_folder.nil?
      render :status => $config.http_errors[:email_folder_not_found][:status_code],
             :json => $config.http_errors[:email_folder_not_found][:description]
      return
    end

    @email_threads = email_folder.get_sorted_paginated_threads(last_email_thread: last_email_thread, dir: params[:dir], threads_per_page: 30)

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :show do
    summary 'Return email thread.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'
    param :query, :page, :integer, :optional, 'Emails page'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end
  # :nocov:

  def show
  end

  # :nocov:
  swagger_api :retrieve do
    summary 'Get email threads.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end
  # :nocov:

  def retrieve
    @email_threads = EmailThread.where(:email_account => @email_account, :uid => params[:email_thread_uids]).to_a()

    @email_threads.sort!() do |left, right|
      left_index = params[:email_thread_uids].find_index(left.uid)
      right_index = params[:email_thread_uids].find_index(right.uid)

      left_index <=> right_index
    end

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :move_to_folder do
    summary 'Move the specified email threads to the specified folder.'
    notes 'If the folder name does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'
    param :form, :email_folder_name, :string, :required, 'Email Folder Name'

    response :ok
  end
  # :nocov:

  def move_to_folder
    emails = Email.where(:id => @email_ids)
    @gmail_label = @email_account.move_emails_to_folder(emails, folder_id: params[:email_folder_id],
                                                        folder_name: params[:email_folder_name])
    render 'api/v1/gmail_labels/show'
  end

  # :nocov:
  swagger_api :apply_gmail_label do
    summary 'Apply the specified Gmail Label to the specified email threads.'
    notes 'If the Gmail Label does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :gmail_label_id, :string, :required, 'Gmail Label ID'
    param :form, :gmail_label_name, :string, :required, 'Gmail Label Name'

    response :ok
  end
  # :nocov:

  def apply_gmail_label
    emails = Email.where(:id => @email_ids)
    @gmail_label = @email_account.apply_label_to_emails(emails, label_id: params[:gmail_label_id],
                                                       label_name: params[:gmail_label_name])
    render 'api/v1/gmail_labels/show'
  end

  # :nocov:
  swagger_api :remove_from_folder do
    summary 'Remove the specified email threads from the specified folder.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end
  # :nocov:

  def remove_from_folder
    emails = Email.where(:id => @email_ids)
    @email_account.remove_emails_from_folder(emails, folder_id: params[:email_folder_id])

    render :json => {}
  end

  # :nocov:
  swagger_api :trash do
    summary 'Move the specified email thread to the trash.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end
  # :nocov:

  def trash
    emails = Email.where(:id => @email_ids)
    @email_account.trash_emails(emails)

    render :json => {}
  end

  # :nocov:
  swagger_api :snooze do
    summary 'Snooze the specified email threads.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :minutes, :string, :required, 'Minutes to snooze'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def snooze
    minutes = params[:minutes].to_i.minutes

    emails = Email.where(:id => @email_ids)
    @email_account.remove_emails_from_folder(emails, folder_id: 'INBOX')
    @email_account.delay({:run_at => DateTime.now() + minutes}, heroku_scale: false).wake_up(@email_ids)

    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @email_thread = EmailThread.find_by(:email_account => current_user.gmail_accounts.first,
                                        :uid => params[:email_thread_uid])

    if @email_thread.nil?
      render :status => $config.http_errors[:email_thread_not_found][:status_code],
             :json => $config.http_errors[:email_thread_not_found][:description]
      return
    end
  end

  def filter_email_thread_uids
    @email_thread_ids = EmailThread.where(:email_account => @email_account, :uid => params[:email_thread_uids]).pluck(:id)
    @email_ids = Email.where(:email_account => @email_account, :email_thread_id => @email_thread_ids).pluck(:id)
  end
end
