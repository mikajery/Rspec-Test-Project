# == Schema Information
#
# Table name: gmail_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  google_id              :text
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  created_at             :datetime
#  updated_at             :datetime
#  sync_delayed_job_id    :integer
#

require 'base64'

require 'gmail_xoauth'

class GmailAccount < ActiveRecord::Base
  MESSAGE_BATCH_SIZE = 100
  DRAFTS_BATCH_SIZE = 100
  HISTORY_BATCH_SIZE = 100
  SEARCH_RESULTS_PER_PAGE = 50
  NUM_SYNC_DYNOS = 3

  SCOPES = %w(https://mail.google.com/
              https://www.googleapis.com/auth/userinfo.email
              https://www.googleapis.com/auth/gmail.readonly
              https://www.googleapis.com/auth/gmail.compose
              https://www.googleapis.com/auth/gmail.modify)

  belongs_to :user

  has_one :google_o_auth2_token,
          :as => :google_api,
          :dependent => :destroy

  has_many :email_threads,
           :as => :email_account,
           :dependent => :destroy

  has_many :emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_attachments,
           :through => :emails

  has_many :people,
           :as => :email_account,
           :dependent => :destroy

  has_many :gmail_labels,
           :dependent => :destroy

  has_many :sync_failed_emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :delayed_emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_trackers,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_tracker_recipients,
           :through => :email_trackers

  has_many :email_tracker_views,
           :through => :email_tracker_recipients

  has_many :list_subscriptions,
           :as => :email_account,
           :dependent => :destroy

  validates :user, :google_id, :email, :verified_email, presence: true

  before_destroy :sync_reset, prepend: true

  # TODO write tests
  def GmailAccount.mime_data_from_gmail_data(gmail_data)
    #Converted to and from JSON to get around a ruby library bug.
    gmail_json = JSON.parse(gmail_data.to_json())

    mime_data = Base64.urlsafe_decode64(gmail_json['raw'])

    return mime_data
  end

  # TODO write tests
  def GmailAccount.email_raw_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    return Email.email_raw_from_mime_data(mime_data)
  end

  # TODO write tests
  def GmailAccount.email_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)

    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  # TODO write tests
  def GmailAccount.init_email_from_gmail_data(email, gmail_data)
    email.uid = gmail_data['id']
    email.snippet = gmail_data['snippet']
  end

  def GmailAccount.get_userinfo(api_client)
    o_auth2_client = Google::OAuth2Client.new(api_client)
    userinfo_data = o_auth2_client.userinfo_get()

    return userinfo_data
  end

  def gmail_client()
    return Google::GmailClient.new(self.google_o_auth2_token.api_client)
  end

  # TODO write tests
  def init_email_from_gmail_data(email, gmail_data)
    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    email.email_account = self
  end

  # TODO write tests
  def gmail_data_from_gmail_id(gmail_id, format = 'raw')
    return self.gmail_client.messages_get('me', gmail_id, format: format)
  end

  # TODO write tests
  def mime_data_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id)
    return GmailAccount.mime_data_from_gmail_data(gmail_data)
  end

  # TODO write tests
  def email_raw_from_gmail_id(gmail_id)
    mime_data = self.mime_data_from_gmail_id(gmail_id)
    return Email.email_raw_from_mime_data(mime_data)
  end

  # TODO write tests
  def email_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id, 'raw')
    email =  GmailAccount.email_from_gmail_data(gmail_data)
    self.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  def inbox_folder
    return self.gmail_labels.find_by_label_id('INBOX')
  end

  def sent_folder
    return self.gmail_labels.find_by_label_id('SENT')
  end

  def drafts_folder
    return self.gmail_labels.find_by_label_id('DRAFT')
  end

  def trash_folder
    return self.gmail_labels.find_by_label_id('TRASH')
  end

  def set_last_history_id_synced(last_history_id_synced)
    self.last_history_id_synced = last_history_id_synced
    self.save!
    log_console("SET last_history_id_synced = #{self.last_history_id_synced}\n")
  end

  def delete_o_auth2_token
    if self.google_o_auth2_token
      self.google_o_auth2_token.destroy()
      self.google_o_auth2_token = nil
    end
  end

  def refresh_user_info(api_client = nil, do_save = true)
    api_client = self.google_o_auth2_token.api_client() if api_client.nil?
    userinfo_data = GmailAccount.get_userinfo(api_client)

    self.google_id = userinfo_data['id']
    self.email = userinfo_data['email'].downcase
    self.verified_email = userinfo_data['verified_email']

    self.save! if do_save
  end

  # TODO write tests
  def recent_thread_subjects(email, max_results: 10)
    query = "from:#{email}"
    threads_list_data = self.gmail_client.threads_list('me', maxResults: max_results,
                                                       q: query, fields: 'threads/id')

    threads_data = threads_list_data['threads']
    thread_uids = threads_data.map { |thread_data| thread_data['id'] }

    thread_subjects = []

    batch_request = Google::APIClient::BatchRequest.new() do |result|
      next if result.error?

      gmail_data = result.data
      messages = gmail_data['messages']
      message = messages[0]

      if message['payload'] && message['payload']['headers'] && message['payload']['headers'].length > 0
        thread_subjects.push(:email_thread_uid => gmail_data['id'], :subject => message['payload']['headers'][0]['value'])
      end
    end

    thread_uids.each do |thread_uid|
      call = self.gmail_client.threads_get_call('me', thread_uid, format: 'metadata', metadataHeaders: 'subject')
      batch_request.add(call)
    end

    self.google_o_auth2_token.api_client.execute!(batch_request)

    return thread_subjects
  end

  def find_or_create_label(label_id: nil, label_name: nil)
    attempts = 1

    begin
      gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => label_id) if label_id
      gmail_label = GmailLabel.find_by(:gmail_account => self,
                                       :name => label_name) if gmail_label.nil? && label_name

      if gmail_label.nil?
        log_console('LABEL DNE! Creating!!')

        if label_id != 'TRASH' && $config.gmail_live
          label_data = self.gmail_client.labels_create('me', label_name || 'New Label')
          gmail_label = sync_label_data(label_data)
        else
          gmail_label = GmailLabel.create!(
            :gmail_account => self,
            :label_id => label_id || SecureRandom.uuid(),
            :name => label_name || 'New Label',
            :label_type => label_id == 'TRASH' ? 'system' : 'user'
          )
        end
      end
    rescue Google::APIClient::ServerError => ex
      if attempts == 1
        self.sync_labels()

        attempts += 1

        retry
      else
        raise ex
      end
    end

    return gmail_label
  end

  # polymorphic call
  def emails_set_seen(emails, seen)
    # this whole method can be converted into a delayed job. Need to discuss with you guys before I do that.
    if seen
      self.remove_emails_from_folder(emails, folder_id: 'UNREAD')
    else
      self.apply_label_to_emails(emails, label_id: 'UNREAD')
    end

    Email.transaction do
      # All records will be saved at once but no callbacks will get executed
      emails.update_all(seen: seen)

      # We will manually update the gmail labels. The benefit is instead of getting executed
      # multiple times this will be executed only once for each label. Can be refactored more.
      gmail_labels = emails.map{|email| email.gmail_labels}.flatten.uniq
      GmailLabel.update_num_unread_threads(gmail_labels)
    end
  end

  # polymorphic call
  def trash_emails(emails)
    if $config.gmail_live
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    emails.each do |email|
      call = self.trash_email(email, batch_request: true, gmail_client: gmail_client)
      batch_request.add(call) if $config.gmail_live
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if $config.gmail_live
  end

  # polymorphic call
  def trash_email(email, batch_request: false, gmail_client: nil)
    log_console("TRASHING #{email.uid}")

    EmailFolderMapping.where(:email => email).destroy_all()
    self.apply_label_to_email(email, label_id: 'TRASH', batch_request: batch_request, gmail_client: gmail_client)

    call = nil
    if $config.gmail_live
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_trash_call('me', email.uid)
      else
        gmail_client.messages_trash('me', email.uid)
      end
    end

    return call
  end

  # polymorphic call
  # TODO write tests
  def wake_up(email_ids)
    emails = Email.where(:id => email_ids)
    self.apply_label_to_emails(emails, label_id: 'INBOX')
  end

  # polymorphic call
  def remove_emails_from_folder(emails, folder_id: nil)
    if folder_id.nil?
      log_console("REMOVING FAILED FROM folder_id IS NIL!")
      return false
    end

    if $config.gmail_live
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    emails.each do |email|
      call = self.remove_email_from_folder(email, folder_id: folder_id,
                                           batch_request: true, gmail_client: gmail_client)

      batch_request.add(call) if $config.gmail_live
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if $config.gmail_live
  end

  # polymorphic call
  def remove_email_from_folder(email, folder_id: nil, batch_request: false, gmail_client: nil)
    if folder_id.nil?
      log_console("REMOVING FAILED #{email.uid} FROM folder_id IS NIL!")
      return false
    end

    log_console("REMOVING #{email.uid} FROM folder_id=#{folder_id}")

    email_folder = GmailLabel.find_by(:gmail_account => self, :label_id => folder_id)
    EmailFolderMapping.where(:email => email.id, :email_folder => email_folder).destroy_all if email_folder

    call = nil
    if $config.gmail_live
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid, removeLabelIds: [folder_id])
      else
        gmail_client.messages_modify('me', email.uid, removeLabelIds: [folder_id])
      end
    end

    return call
  end

  # polymorphic call
  def move_emails_to_folder(emails, folder_id: nil, folder_name: nil, set_auto_filed_folder: false)
    if folder_id.nil? && folder_name.nil?
      log_console("MOVING FAILED #{emails.pluck(:uid).join(', ')} TO folder_id AND folder_name are NIL!")
      return false
    end

    if $config.gmail_live
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    gmail_label = nil
    emails.each do |email|
      gmail_label, call = self.move_email_to_folder(email, folder_id: folder_id, folder_name: folder_name,
                                                    set_auto_filed_folder: set_auto_filed_folder,
                                                    batch_request: true, gmail_client: gmail_client)

      batch_request.add(call) if $config.gmail_live
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if $config.gmail_live

    return gmail_label
  end

  # polymorphic call
  def move_email_to_folder(email, folder_id: nil, folder_name: nil, set_auto_filed_folder: false,
                           batch_request: false, gmail_client: nil)
    if folder_id.nil? && folder_name.nil?
      log_console("MOVING FAILED #{email.uid} TO folder_id AND folder_name are NIL!")
      return false
    end

    log_console("MOVING #{email.uid} TO folder_id=#{folder_id} folder_name=#{folder_name}")

    if $config.gmail_live
      removeLabelIds = email.gmail_labels.pluck(:label_id)
      removeLabelIds.delete(folder_id)
      removeLabelIds.delete('SENT')
    end

    EmailFolderMapping.destroy_all(:email => email)
    gmail_label, ignore = self.apply_label_to_email(email, label_id: folder_id, label_name: folder_name,
                                                    set_auto_filed_folder: set_auto_filed_folder,
                                                    batch_request: batch_request, gmail_client: gmail_client)
    call = nil
    if $config.gmail_live
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid,
                                                 addLabelIds: [gmail_label.label_id],
                                                 removeLabelIds: removeLabelIds)
      else
        gmail_client.messages_modify('me', email.uid,
                                     addLabelIds: [gmail_label.label_id],
                                     removeLabelIds: removeLabelIds)
      end
    end

    return [gmail_label, call]
  end

  def apply_label_to_emails(emails, label_id: nil, label_name: nil,
                            set_auto_filed_folder: false)
    if label_id.nil? && label_name.nil?
      log_console("APPLY LABEL TO #{emails.pluck(:uid).join(', ')} FAILED label_id=#{label_id} label_name=#{label_name}")
      return false
    end

    if $config.gmail_live
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    gmail_label = nil
    emails.each do |email|
      gmail_label, call = self.apply_label_to_email(email, label_id: label_id, label_name: label_name,
                                                    set_auto_filed_folder: set_auto_filed_folder,
                                                    batch_request: true, gmail_client: gmail_client)

      batch_request.add(call) if $config.gmail_live
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if $config.gmail_live

    return gmail_label
  end

  def apply_label_to_email(email, label_id: nil, label_name: nil, set_auto_filed_folder: false,
                           batch_request: false, gmail_client: nil, gmail_sync: true)
    if label_id.nil? && label_name.nil?
      log_console("APPLY LABEL TO #{email.uid} FAILED label_id=#{label_id} label_name=#{label_name}")
      return nil
    end

    if label_id != 'UNREAD'
      gmail_label = self.find_or_create_label(label_id: label_id, label_name: label_name)
      gmail_label.apply_to_emails([email])

      label_id_final = gmail_label.label_id
    else
      gmail_label = nil
      label_id_final = label_id
    end

    call = nil
    if gmail_sync && $config.gmail_live && label_id_final != 'TRASH'
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid, addLabelIds: [label_id_final])
      else
        gmail_client.messages_modify('me', email.uid, addLabelIds: [label_id_final])
      end
    end

    if set_auto_filed_folder
      email.auto_filed_folder = gmail_label
      email.save!
    end

    return [gmail_label, call]
  end

  def search_threads(query, nextPageToken = nil, max_results = GmailAccount::SEARCH_RESULTS_PER_PAGE)
    log_console("SEARCH threads query=#{query} nextPageToken=#{nextPageToken} max_results=#{max_results}")

    threads_list_data = self.gmail_client.threads_list('me', maxResults: max_results,
                                                            pageToken: nextPageToken,
                                                            q: query, fields: 'nextPageToken,threads/id')

    threads_data = threads_list_data['threads']
    thread_uids = threads_data.map { |thread_data| thread_data['id'] }
    nextPageToken = threads_list_data['nextPageToken']

    log_console("FOUND #{threads_data.length} threads nextPageToken=#{nextPageToken}")

    return thread_uids, nextPageToken
  end

  def process_sync_failed_emails(delay: true)
    log_console("process_sync_failed_emails #{self.sync_failed_emails.count} emails!")

    gmail_ids = self.sync_failed_emails.pluck(:email_uid)
    self.sync_failed_emails.where(:email_uid => gmail_ids).delete_all()

    if gmail_ids.length > 0
      if delay
        job = self.delay(num_dynos: GmailAccount::NUM_SYNC_DYNOS).sync_gmail_ids(gmail_ids, delay: false)

        return [job.id]
      else
        self.sync_gmail_ids(gmail_ids, delay: false)
        return []
      end
    end

    return []
  end

  def sync_reset(reset_history_id = true)
    EmailFolderMapping.where(:email => self.emails).delete_all
    log_console('EmailFolderMapping DELETED!')

    EmailRecipient.where(:email => self.emails).delete_all
    log_console('EmailRecipient(email) DELETED!')

    EmailReference.where(:email => self.emails).delete_all
    log_console('EmailReference DELETED!')

    EmailInReplyTo.where(:email => self.emails).delete_all
    log_console('EmailInReplyTo DELETED!')

    destroy_all_batch(EmailAttachment.where(:email => self.emails).where('s3_key IS NOT NULL'))
    log_console('EmailAttachment destroyed!!!')
    EmailAttachment.where(:email => self.emails).delete_all
    log_console('EmailAttachment DELETED!')

    destroy_all_batch(EmailTrackerRecipient.where(:email => self.emails))
    log_console('EmailTrackerRecipient destroyed!!!')

    self.emails.delete_all
    log_console('Email DELETED!')

    self.email_threads.delete_all
    log_console('Email Threads DELETED!')

    EmailRecipient.where(:person => self.people).delete_all
    log_console('EmailRecipient(person) DELETED!')

    self.people.delete_all
    log_console('People DELETED!')

    SyncFailedEmail.where(:email_account => self).delete_all
    log_console('SyncFailedEmail DELETED!')

    ListSubscription.where(:email_account => self).delete_all
    log_console('ListSubscription DELETED!')

    destroy_all_batch(self.gmail_labels)
    log_console('gmail_labels destroyed!!!')

    self.sync_started_time = nil
    self.last_history_id_synced = nil if reset_history_id

    self.save!
  end

  def check_initial_sync(job_ids)
    num_jobs_pending = Delayed::Job.where(:id => job_ids, :failed_at => nil).count

    if num_jobs_pending == 0
      log_console("#{self.user.email} INITIAL SYNC DONE!!")

      EmailGenie.run_brain_and_report(self, true)
    else
      log_console("#{self.user.email} initial sync NOT DONE num_jobs_pending=#{num_jobs_pending}!!")

      self.delay({run_at: 1.minute.from_now}, num_dynos: GmailAccount::NUM_SYNC_DYNOS).check_initial_sync(job_ids)
    end
  end

  def queue_sync_account
    unless sync_lock
      SyncAccountJob.perform_later(self)

      update_attributes(sync_lock: true)
    end
  end

  def sync_account
    log_console("sync_account for #{self.email}")

    self.sync_labels()
    self.sync_email(delay: false)
  end

  def sync_email(labelIds: nil, delay: true)
    log_console("SYNCING Gmail #{self.email}")

    started_sync = false

    self.with_lock do
      if self.sync_started_time
        seconds_since_sync_started = ((DateTime.now() - self.sync_started_time.to_datetime()) * 24 * 60 * 60).to_i

        if seconds_since_sync_started < 2.hours
          log_console("SKIPPING SYNC because seconds_since_sync_started=#{seconds_since_sync_started}")
          return []
        else
          log_console("DOING SYNC! with seconds_since_sync_started=#{seconds_since_sync_started}")
        end
      end

      started_sync = true
      self.sync_started_time = DateTime.now()
      self.save!
    end

    job_ids = self.process_sync_failed_emails(delay: delay)

    if self.last_history_id_synced.nil? || !self.user.has_genie_report_ran
      log_console ('INITIAL SYNC!!')

      job_ids.concat(self.sync_email_full(labelIds: labelIds, delay: delay))
      job_ids.concat(self.sync_email_partial(delay: delay)) if labelIds.blank?

      self.sync_draft_ids()

      if !self.user.has_genie_report_ran
        job_ids.concat(self.sync_email_full(labelIds: 'SENT', delay: delay))

        log_console("#{self.user.email} queueing check_initial_sync with #{job_ids.length} job IDs!")
        self.delay(num_dynos: GmailAccount::NUM_SYNC_DYNOS).check_initial_sync(job_ids)
      end
    else
      log_console ("SUBSEQUENT SYNC!!")

      job_ids.concat(self.sync_email_partial(delay: delay))

      self.sync_draft_ids()
    end

    log_console("#{self.user.email} sync_email got #{job_ids.length} job IDs!")

    return job_ids
  rescue Signet::AuthorizationError => ex
    return job_ids
  rescue Google::APIClient::ClientError => ex
    if ex.result.data.error &&
        !ex.result.data.error['errors'].empty? &&
        ex.result.data.error['errors'][0]['reason'] == 'authError'
      log_console("sync_email_partial #{self.email} EMAIL AUTH ERROR")
      return job_ids
    else
      raise ex
    end
  ensure
    if started_sync
      self.sync_started_time = nil
      self.save!
    end
  end

  def sync_labels()
    log_console("SYNCING Gmail LABELS #{self.email}")

    labels_list_data = self.gmail_client.labels_list('me')
    labels_data = labels_list_data['labels']
    log_console("GOT #{labels_data.length} labels\n")

    labels_data.each { |label_data| self.sync_label_data(label_data) }
  end

  def sync_label_data(label_data)
    gmail_label = nil

    begin
      #log_console("SYNCING Gmail LABEL #{label_data['id']} #{label_data['name']} #{label_data['type']}")

      retry_block(sleep_seconds: 1) do
        gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => label_data['id'])
        gmail_label = GmailLabel.find_by(:gmail_account => self, :name => label_data['name']) if gmail_label.nil?
        gmail_label = GmailLabel.new(:gmail_account => self, :label_id => label_data['id']) if gmail_label.nil?

        gmail_label.label_id = label_data['id']
        gmail_label.name = label_data['name']
        gmail_label.message_list_visibility = label_data['messageListVisibility']
        gmail_label.label_list_visibility = label_data['labelListVisibility']
        gmail_label.label_type = label_data['type'] || 'user'

        gmail_label.save!
      end
    rescue ActiveRecord::RecordNotUnique => unique_violation
      log_console('UNIQUE violation!!')

      raise unique_violation
    end

    return gmail_label
  end

  def sync_email_labels(email, gmail_label_ids)
    email.email_folder_mappings.destroy_all()

    email.seen = gmail_label_ids.nil? || !gmail_label_ids.include?('UNREAD')
    email.save!

    if gmail_label_ids
      gmail_label_ids.each do |gmail_label_id|
        #log_console("SYNCING LABEL #{gmail_label_id}!")

        next if gmail_label_id == 'UNREAD'

        gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => gmail_label_id)
        if gmail_label.nil?
          label_data = self.gmail_client.labels_get('me', gmail_label_id)
          gmail_label = self.sync_label_data(label_data)

          log_console("created #{gmail_label_id}")
        end

        self.apply_label_to_email(email, label_id: gmail_label.label_id, label_name: gmail_label.name,
                                  gmail_sync: false)
      end
    end
  end

  def sync_email_full(labelIds: nil, delay: true)
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    job_ids = []
    num_emails_synced = 0
    nextPageToken = nil
    last_history_id_synced = nil

    HerokuTools::HerokuTools.scale_dynos('worker', GmailAccount::NUM_SYNC_DYNOS) if delay

    while true
      log_console("SYNCING page = #{nextPageToken}")

      attempts = 0
      begin
        retry_block(log: true, exceptions_to_ignore: [Google::APIClient::ClientError]) do
          messages_list_data = self.gmail_client.messages_list('me', pageToken: nextPageToken, labelIds: labelIds,
                                                               maxResults: Google::Misc::MAX_BATCH_REQUESTS)
          messages_data = messages_list_data['messages']
          log_console("GOT #{messages_data.length} messages\n")

          gmail_ids = messages_data.map { |message_data| message_data['id'] }

          if labelIds.blank? && last_history_id_synced.nil?
            gmail_data = self.gmail_client.messages_get('me', gmail_ids.first, format: 'minimal', fields: 'historyId')
            last_history_id_synced = gmail_data['historyId']
          end

          #job_ids.concat(self.sync_gmail_ids(gmail_ids, delay: delay))
          if delay
            job = self.delay(heroku_scale: false).sync_gmail_ids(gmail_ids, delay: false)
            job_ids.push(job.id)
          else
            self.sync_gmail_ids(gmail_ids, delay: false)
          end

          num_emails_synced += gmail_ids.length

          nextPageToken = messages_list_data['nextPageToken']
        end
      rescue Google::APIClient::ClientError => ex
        attempts = Google::GmailClient.handle_client_error(ex, attempts)
        retry
      end

      sleep(1)

      log_console("SYNCED #{num_emails_synced} TOTAL so far!")

      break if nextPageToken.blank?
    end

    self.set_last_history_id_synced(last_history_id_synced) if last_history_id_synced

    return job_ids
  rescue Signet::AuthorizationError => ex
    return job_ids
  rescue Google::APIClient::ClientError => ex
    if ex.result.data.error &&
        !ex.result.data.error['errors'].empty? &&
        ex.result.data.error['errors'][0]['reason'] == 'authError'
      log_console("sync_email_partial #{self.email} EMAIL AUTH ERROR")
      return job_ids
    else
      raise ex
    end
  rescue Exception => ex
    log_console('AHHHHHHH sync_email_full self.gmail_client.messages_list FAILED')
    raise ex
  end

  def sync_email_partial(delay: true)
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    job_ids = []
    num_emails_synced = 0
    nextPageToken = nil

    HerokuTools::HerokuTools.scale_dynos('worker', GmailAccount::NUM_SYNC_DYNOS) if delay

    while true
      log_console("SYNCING page = #{nextPageToken}")

      attempts = 0
      begin
        retry_block(log: true, exceptions_to_ignore: [Google::APIClient::ClientError]) do
          history_list_data = self.gmail_client.history_list('me', pageToken: nextPageToken,
                                                             startHistoryId: self.last_history_id_synced,
                                                             maxResults: GmailAccount::HISTORY_BATCH_SIZE)
          historys_data = history_list_data['history']
          log_console("GOT #{historys_data.length} history items")

          gmail_ids = []

          historys_data.each do |history_data|
            messages_data = history_data['messages']
            gmail_ids.concat(messages_data.map { |message_data| message_data['id'] })
          end

          log_console("GOT #{gmail_ids.length} messages\n")

          if gmail_ids.length > 0
            if delay
              job = self.delay(heroku_scale: false).sync_gmail_ids(gmail_ids, delay: false)
              job_ids.push(job.id)
            else
              self.sync_gmail_ids(gmail_ids, delay: false)

              self.set_last_history_id_synced(historys_data.last['id']) if !historys_data.empty?
            end

            num_emails_synced += gmail_ids.length
          end

          nextPageToken = history_list_data['nextPageToken']
        end
      rescue Signet::AuthorizationError => ex
        return job_ids
      rescue Google::APIClient::ClientError => ex
        if ex.result.status == 404
          log_console("HISTORY ID #{self.last_history_id_synced} NOT FOUND!!!!!!!!!!!!!")
          self.set_last_history_id_synced(nil)

          full_sync_job_ids = sync_email_full(delay: delay)
          return job_ids.concat(full_sync_job_ids)
        elsif ex.result.data.error &&
              !ex.result.data.error['errors'].empty? &&
              ex.result.data.error['errors'][0]['reason'] == 'authError'
          log_console("sync_email_partial #{self.email} EMAIL AUTH ERROR")
          return job_ids
        else
          attempts = Google::GmailClient.handle_client_error(ex, attempts)
          retry
        end
      end

      sleep(1)

      break if nextPageToken.blank?
    end

    return job_ids
  rescue Exception => ex
    log_console('AHHHHHHH sync_email_partial self.gmail_client.history_list FAILED')
    raise ex
  end

  def create_email_from_gmail_data(gmail_data)
    email_raw = GmailAccount.email_raw_from_gmail_data(gmail_data)
    email = Email.email_from_email_raw(email_raw)
    self.init_email_from_gmail_data(email, gmail_data)

    begin
      gmail_thread_id = gmail_data['threadId']

      email_thread = EmailThread.find_or_create_by!(:email_account => self,
                                                    :uid => gmail_thread_id)
      email_thread.with_lock do
        email_thread.email_account = self
        email.email_thread = email_thread
        email.save!

        email.with_lock do
          email.add_references(email_raw)
          email.add_in_reply_tos(email_raw)
          email.add_recipients(email_raw)
          email.add_attachments(email_raw)

          list_subscription = ListSubscription.create_from_email_raw(self, email_raw)
          email.list_subscription = list_subscription
          email.save!
        end
      end

      self.sync_email_labels(email, gmail_data['labelIds'])

      self.user.apply_email_rules_to_email(email) if gmail_data['labelIds'].include?("INBOX")

      if email.list_subscription
        if self.list_subscriptions.where(:list_id => email.list_subscription.list_id,
                                         :list_name => email.list_subscription.list_name,
                                         :list_domain => email.list_subscription.list_domain,
                                         :unsubscribed => true).count > 0
          log_console("email with subject=#{email.subject} from UNSUBSCRIBED list!! trashing")

          self.trash_email(email)
        end
      end
    rescue ActiveRecord::RecordNotUnique => unique_violation
      raise unique_violation if unique_violation.message !~ /index_emails_on_email_account_type_and_email_account_id_and_uid/ &&
                                unique_violation.message !~ /index_emails_on_email_account_id_and_email_account_type_and_uid/
      email = Email.find_by_uid(gmail_data['id'])
      raise 'AHHHHHHHHHH unique_violation but NO email?!' if email.nil?

      self.sync_email_labels(email, gmail_data['labelIds'])
    end
  rescue SignalException => ex
    raise ex
  rescue Exception => ex
    SyncFailedEmail.create_retry(self, gmail_data['id'], ex: ex)
  end

  def update_email_from_gmail_data(gmail_data)
    email = Email.find_by_uid(gmail_data['id'])
    if email.nil?
      SyncFailedEmail.create_retry(self, gmail_data['id'], 'update_email_from_gmail_data Email GONE!!!')
      return
    end

    self.sync_email_labels(email, gmail_data['labelIds'])
  end

  def sync_gmail_ids_batch_request(delay: false, job_ids: [])
    return Google::APIClient::BatchRequest.new() do |result|
      if result.error?
        if result.response.status == 404
          log_console("DELETED = #{result.request.parameters['id']}")
          Email.destroy_all(:email_account => self,
                            :uid => result.request.parameters['id'])
          next
        else
          SyncFailedEmail.create_retry(self, result.request.parameters['id'], result: result)
          next
        end
      end

      gmail_data = result.data
      #log_console("SYNC PROCESSING message.id = #{gmail_data['id']}")

      begin
        if delay
          if gmail_data['raw']
            job = self.delay(heroku_scale: false).create_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          else
            #log_console('EXISTS - minimal update!')
            job = self.delay(heroku_scale: false).update_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          end

          job_ids.push(job.id)
        else
          if gmail_data['raw']
            self.create_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          else
            #log_console('EXISTS - minimal update!')
            self.update_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          end
        end
      rescue SignalException => ex
        raise ex
      rescue Exception => ex
        SyncFailedEmail.create_retry(self, gmail_data['id'], ex: ex)
      end
    end
  end

  def sync_gmail_id(gmail_id)
    log_console("sync_gmail_id PROCESSING message.id = #{gmail_id}")

    email = Email.find_by_uid(gmail_id)
    format = email ? 'minimal' : 'raw'

    retry_block do
      gmail_data = gmail_client.messages_get('me', gmail_id, format: format)

      if gmail_data['raw']
        self.create_email_from_gmail_data(JSON.parse(gmail_data.to_json))
      else
        self.update_email_from_gmail_data(JSON.parse(gmail_data.to_json))
      end
    end
  rescue SignalException => ex
    raise ex
  rescue Exception => ex
    result = ex.result

    if result.status == 404
      log_console("DELETED = #{result.request.parameters['id']}")
      Email.destroy_all(:email_account => self,
                        :uid => gmail_id)
    else
      SyncFailedEmail.create_retry(self, gmail_id, result: result)
    end
  end

  def sync_gmail_ids(gmail_ids_orig, delay: false)
    GmailLabel.skip_update_counts = true

    gmail_ids = gmail_ids_orig.dup.uniq
    gmail_id_index = 0
    job_ids = []


    log_console("sync_gmail_ids with #{gmail_ids.length} gmail ids and delay=#{delay}!")

    HerokuTools::HerokuTools.scale_dynos('worker', GmailAccount::NUM_SYNC_DYNOS) if delay

    while gmail_id_index < gmail_ids.length
      retry_block do
        current_gmail_ids = gmail_ids[gmail_id_index ... (gmail_id_index + GmailAccount::MESSAGE_BATCH_SIZE)]

        if !delay
          email_uids = Email.where(:uid => current_gmail_ids).pluck(:uid)

          batch_request = self.sync_gmail_ids_batch_request(delay: delay, job_ids: job_ids)
          gmail_client = self.gmail_client

          current_gmail_ids.each do |gmail_id|
            format = email_uids.include?(gmail_id) ? 'minimal' : 'raw'
            #log_console("QUEUEING message SYNC format=#{format} gmail_id = #{gmail_id}")

            call = gmail_client.messages_get_call('me', gmail_id, format: format)
            batch_request.add(call)
          end

          self.google_o_auth2_token.api_client.execute!(batch_request)
        else
          current_gmail_ids.each do |gmail_id|
            job = self.delay(heroku_scale: false).sync_gmail_id(gmail_id)

            job_ids.push(job.id)
          end
        end

        gmail_id_index += GmailAccount::MESSAGE_BATCH_SIZE
      end
    end

    return job_ids
  rescue Signet::AuthorizationError => ex
    return job_ids
  rescue Google::APIClient::ClientError => ex
    if ex.result.data.error &&
        !ex.result.data.error['errors'].empty? &&
        ex.result.data.error['errors'][0]['reason'] == 'authError'
      log_console("sync_email_partial #{self.email} EMAIL AUTH ERROR")
      return job_ids
    else
      raise ex
    end
  ensure
    GmailLabel.skip_update_counts = false
    GmailLabel.update_counts(self.gmail_labels)
  end

  def sync_gmail_thread(gmail_thread_id)
    log_console("SYNCING gmail_thread_id = #{gmail_thread_id}")
    thread_data = self.gmail_client.threads_get('me', gmail_thread_id, fields: 'messages(id)')
    messages_data = thread_data['messages']
    log_console("thread has #{messages_data.length} messages!")

    gmail_ids = []
    messages_data.each { |message_data| gmail_ids.push(message_data['id']) }
    self.sync_gmail_ids(gmail_ids)
  end

  def send_email_raw(email_raw, email_in_reply_to)
    if email_in_reply_to
      gmail_data = self.gmail_client.messages_send('me', :threadId => email_in_reply_to.email.uid,
                                                   :email_raw => email_raw)
    else
      gmail_data = self.gmail_client.messages_send('me', :email_raw => email_raw)
    end

    gmail_id = gmail_data['id']
    self.sync_gmail_ids([gmail_id])
    email = self.emails.find_by(:uid => gmail_id)

    return email
  end

  def send_email(tos = nil, ccs = nil, bccs = nil,
                 subject = nil,
                 html_part = nil, text_part = nil,
                 email_in_reply_to_uid = nil,
                 tracking_enabled = false,
                 bounce_back = false, bounce_back_time = nil, bounce_back_type = nil,
                 attachment_s3_keys = [])
    attachment_s3_keys = [] if attachment_s3_keys.nil?
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid,
                                                               attachment_s3_keys)

    email = nil

    self.google_o_auth2_token.refresh()

    email_raw.From = self.email
    email_raw.delivery_method.settings = {
        :enable_starttls_auto => true,
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => $config.smtp_helo_domain,
        :user_name            => self.email,
        :password             => self.google_o_auth2_token.access_token,
        :authentication       => :xoauth2,
        :enable_starttls      => true
    }

    if tracking_enabled
      log_console('tracking_enabled = true!!!!!!')

      html_part = '' if html_part.nil?

      email_message_ids = []

      email_tracker = EmailTracker.new()
      email_tracker.uid = SecureRandom.uuid()
      email_tracker.email_account = self
      email_tracker.email_subject = subject
      email_tracker.email_date = DateTime.now()
      email_tracker.save!()

      email_recipients = []
      email_recipients += tos if tos
      email_recipients += ccs if ccs
      email_recipients += bccs if bccs

      email_recipients.each do |rcpt_to|
        next if rcpt_to.blank?

        log_console("rcpt_to = #{rcpt_to}")

        email_tracker_recipient = EmailTrackerRecipient.new()
        email_tracker_recipient.email_tracker = email_tracker
        email_tracker_recipient.uid = SecureRandom.uuid()
        email_tracker_recipient.email_address = rcpt_to

        email_raw.html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body html_part + "<img src=\"#{$url_helpers.confirmation_url(email_tracker_recipient.uid)}\" />"
        end

        email_raw.smtp_envelope_to = rcpt_to
        email_raw.message_id = nil

        retry_block do
          email_raw.deliver!
        end

        email_tracker_recipient.email = email
        email_tracker_recipient.save!()

        email_message_ids.push(email_raw.message_id)
      end

      self.sync_email(delay: false)

      email_tracker.email_uids = []
      email_message_ids.each do |message_id|
        email = self.emails.find_by_message_id(message_id)
        email_tracker.email_uids.push(email.uid) if email
      end

      email_tracker.save!()
    else
      log_console('NO tracking_enabled')

      retry_block do
        email_raw.deliver!
      end

      self.sync_email(delay: false)
      email = self.emails.find_by_message_id(email_raw.message_id)
    end

    if email && bounce_back
      log_console("BOUNCE BACK!! #{bounce_back_time} #{bounce_back_type}")
      email.bounce_back = bounce_back
      email.bounce_back_time = bounce_back_time
      email.bounce_back_type = bounce_back_type

      job = email.delay({:run_at => bounce_back_time}, heroku_scale: false).run_bounce_back()
      email.bounce_back_job_id = job.id

      email.save!
    end

    attachment_s3_keys.each do |attachment_s3_key|
      parts = attachment_s3_key.split(/\//)

      s3_key = parts[2]
      email_attachment_upload = email.user.email_attachment_uploads.find_by_s3_key(s3_key)
      log_exception() { email_attachment_upload.destroy!() if email_attachment_upload }
    end

    return email
  end

  def get_draft_ids()
    log_console('GET DRAFTS')

    draft_ids = {}

    nextPageToken = nil

    while true
      drafts_list_data = self.gmail_client.drafts_list('me', pageToken: nextPageToken,
                                                       maxResults: GmailAccount::DRAFTS_BATCH_SIZE)
      drafts_data = drafts_list_data['drafts']
      log_console("GOT #{drafts_data.length} drafts")

      drafts_data.each do |draft_data|
        gmail_id = draft_data['message']['id']
        draft_id = draft_data['id']

        draft_ids[gmail_id] = draft_id
      end

      nextPageToken = drafts_list_data['nextPageToken']
      break if nextPageToken.nil?
    end

    return draft_ids
  end

  # TODO write tests
  def sync_draft_ids
    draft_ids = self.get_draft_ids()

    draft_ids.each do |gmail_id, draft_id|
      self.emails.where(:uid => gmail_id).update_all(:draft_id => draft_id)
    end
  end

  def sync_draft_data(draft_data, attachment_s3_keys)
    draft_id = draft_data['id']
    gmail_id = draft_data['message']['id']

    self.emails.where(:draft_id => draft_id).destroy_all()

    sync_gmail_ids([gmail_id])
    draft_email = self.emails.find_by(:uid => gmail_id)
    draft_email.draft_id = draft_id
    draft_email.save!

    attachment_s3_keys.each do |attachment_s3_key|
      parts = attachment_s3_key.split(/\//)

      s3_key = parts[2]

      email_attachment_upload = self.user.email_attachment_uploads.find_by_s3_key(s3_key)

      if email_attachment_upload
        email_attachment_upload.email = draft_email
        email_attachment_upload.filename = parts[-1]
        email_attachment_upload.s3_key_full = attachment_s3_key
        email_attachment_upload.save!()
      end
    end

    EmailFolderMapping.where(:email => draft_email).update_all(:folder_email_draft_id => draft_id)

    return draft_email
  end

  def create_draft(tos, ccs, bccs, subject, html_part, text_part, email_in_reply_to_uid = nil, attachment_s3_keys = [])
    attachment_s3_keys = [] if attachment_s3_keys.nil?
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid,
                                                               attachment_s3_keys)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_create('me', :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_create('me', :email_raw => email_raw)
    end

    return sync_draft_data(draft_data, attachment_s3_keys)
  end

  def update_draft(draft_id, tos, ccs, bccs, subject, html_part, text_part, attachment_s3_keys = [])
    attachment_s3_keys = [] if attachment_s3_keys.nil?
    email = self.emails.find_by(:draft_id => draft_id)
    if email
      email_in_reply_to_uid = email.email_references.order(:position).last.email.uid if email.email_references.count > 0

      if email_in_reply_to_uid.nil?
        email_in_reply_to_uid = email.email_in_reply_tos.order(:position).last.email.uid if email.email_references.count > 0
      end
    end

    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid, attachment_s3_keys)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_update('me', draft_id,
                                                   :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_update('me', draft_id, :email_raw => email_raw)
    end

    return sync_draft_data(draft_data, attachment_s3_keys)
  end

  def send_draft(draft_id)
    email = self.emails.find_by_draft_id(draft_id)
    return nil if email.nil?
    email_raw = self.email_raw_from_gmail_id(email.uid)

    self.google_o_auth2_token.refresh()

    email_raw.From = self.email
    email_raw.delivery_method.settings = {
        :enable_starttls_auto => true,
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => $config.smtp_helo_domain,
        :user_name            => self.email,
        :password             => self.google_o_auth2_token.access_token,
        :authentication       => :xoauth2,
        :enable_starttls      => true
    }

    retry_block do
      email_raw.deliver!
    end

    self.delete_draft(draft_id)

    self.sync_email(delay: false)
    email = self.emails.find_by_message_id(email_raw.message_id)

    return email
  end

  def delete_draft(draft_id)
    self.gmail_client.drafts_delete('me', draft_id)
    email = self.emails.find_by(:draft_id => draft_id)
    email.destroy if email
  end

  # :nocov:
  def apply_cleaner
    if $config.gmail_live
      batch_request = EmailGenie.new_gmail_batch_request()
      gmail_client = self.gmail_client
      batch_empty = true
    end

    self.emails.where(:auto_filed => false).
                where('auto_file_folder_name IS NOT NULL').find_each do |email|
      log_exception() do
        gmail_label, call = self.move_email_to_folder(email, folder_name: email.auto_file_folder_name,
                                                      set_auto_filed_folder: true,
                                                      batch_request: batch_request,
                                                      gmail_client: gmail_client)
        email.auto_filed = true
        email.auto_file_folder_name = nil
        email.queued_auto_file = false
        email.save!

        if $config.gmail_live
          batch_request.add(call)
          batch_empty = false

          if batch_request.calls.length == 5
            self.google_o_auth2_token.api_client.execute!(batch_request)
            batch_request = EmailGenie.new_gmail_batch_request()
            batch_empty = true

            sleep(1)
          end
        end
      end
    end
  end
  # :nocov:
end
