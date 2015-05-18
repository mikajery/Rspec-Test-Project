# == Schema Information
#
# Table name: emails
#
#  id                                :integer          not null, primary key
#  email_account_id                  :integer
#  email_account_type                :string(255)
#  email_thread_id                   :integer
#  ip_info_id                        :integer
#  auto_filed                        :boolean          default(FALSE)
#  auto_filed_reported               :boolean          default(FALSE)
#  auto_filed_folder_id              :integer
#  auto_filed_folder_type            :string(255)
#  uid                               :text
#  draft_id                          :text
#  message_id                        :text
#  list_name                         :text
#  list_id                           :text
#  seen                              :boolean          default(FALSE)
#  snippet                           :text
#  date                              :datetime
#  from_name                         :text
#  from_address                      :text
#  sender_name                       :text
#  sender_address                    :text
#  reply_to_name                     :text
#  reply_to_address                  :text
#  tos                               :text
#  ccs                               :text
#  bccs                              :text
#  subject                           :text
#  html_part                         :text
#  text_part                         :text
#  body_text                         :text
#  has_calendar_attachment           :boolean          default(FALSE)
#  list_subscription_id              :integer
#  bounce_back                       :boolean          default(FALSE)
#  bounce_back_time                  :datetime
#  bounce_back_type                  :text
#  bounce_back_job_id                :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  auto_file_folder_name             :string(255)
#  queued_auto_file                  :boolean          default(FALSE)
#  upload_attachments_delayed_job_id :integer
#  attachments_uploaded              :boolean          default(FALSE)
#

require 'tmpdir'

class Email < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  belongs_to :email_thread, counter_cache: true

  belongs_to :ip_info

  belongs_to :auto_filed_folder, polymorphic: true

  has_many :email_folder_mappings,
           :dependent => :destroy
  has_many :imap_folders, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'ImapFolder'
  has_many :gmail_labels, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'GmailLabel'

  has_many :email_recipients,
           :dependent => :destroy

  has_many :email_references,
           :dependent => :destroy

  has_many :email_in_reply_tos,
           :dependent => :destroy

  has_many :email_attachments,
           :dependent => :destroy

  has_many :email_tracker_recipients,
           :dependent => :destroy

  has_many :email_tracker_views,
           :through => :email_tracker_recipients

  has_many :email_attachment_uploads

  belongs_to :list_subscription

  attr_accessor :attachment_s3_keys

  enum :bounce_back_type => {
    :always => 'always',
    :not_opened => 'not_opened',
    :not_clicked => 'not_clicked',
    :no_reply => 'no_reply'
  }

  validates :email_account, :uid, :email_thread_id, presence: true

  after_create {
    EmailFolderMapping.where(:email_thread => self.email_thread).
                       update_all(:folder_email_thread_date => self.email_thread.emails.maximum(:date))
  }

  after_update {
    if self.seen_changed?
      self.gmail_labels.each do |gmail_label|
        gmail_label.update_num_unread_threads()
      end
    end
  }

  after_commit :update_sync_time, on: :update

  def update_sync_time
    # update the last_updated_at time in email_account. Downside: this will slow down mass email update. Till I figure out a better solution
    email_account.update_attribute :last_sync_at, self.updated_at
  end

  def Email.lists_email_daily_average(user, limit: nil, where: nil)
    return user.emails.where("list_id IS NOT NULL").where(where).
                group(:list_name, :list_id).order('daily_average DESC').limit(limit).
                pluck('list_name, list_id, COUNT(*) / (1 + EXTRACT(day FROM now() - MIN(date))) AS daily_average')
  end

  def Email.email_raw_from_params(tos = nil, ccs = nil, bccs = nil,
                                  subject = nil,
                                  html_part = nil, text_part = nil,
                                  email_account = nil, email_in_reply_to_uid = nil,
                                  attachment_s3_keys = [])
    attachment_s3_keys = [] if attachment_s3_keys.nil?

    email_raw = Mail.new do
      to tos
      cc ccs
      bcc bccs
      subject subject
    end

    email_raw.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body html_part
    end

    email_raw.text_part = Mail::Part.new do
      body text_part
    end

    email_in_reply_to = nil
    if !email_in_reply_to_uid.blank?
      email_in_reply_to = email_account.emails.includes(:email_thread).find_by(:uid => email_in_reply_to_uid)

      if email_in_reply_to
        log_console("FOUND email_in_reply_to=#{email_in_reply_to.id}")
        Email.add_reply_headers(email_raw, email_in_reply_to)
      end
    end

    s3_bucket = s3_get_bucket()

    attachment_s3_keys.each do |attachment_s3_key|
      object = s3_bucket.objects[attachment_s3_key]
      parts = attachment_s3_key.split(/\//)

      begin
        dir = Dir.mktmpdir($config.service_name_short.downcase)
        path = "#{dir}/#{parts[-1]}"

        open(path, 'wb') do |file|
          object.read do |chunk|
            file.write(chunk)
          end
        end

        email_raw.add_file(path)
      ensure
        FileUtils.remove_entry_secure dir
      end
    end

    return email_raw, email_in_reply_to
  end

  def Email.email_raw_from_mime_data(mime_data)
    mail_data_file = Tempfile.new($config.service_name_short.downcase)
    mail_data_file.binmode

    mail_data_file.write(mime_data)
    mail_data_file.close()
    email_raw = Mail.read(mail_data_file.path)
    FileUtils.remove_entry_secure(mail_data_file.path)

    return email_raw
  end

  def Email.email_from_mime_data(mime_data)
    email_raw = Email.email_raw_from_mime_data(mime_data)
    return Email.email_from_email_raw(email_raw)
  end

  def Email.email_from_email_raw(email_raw)
    email = Email.new

    ip = Email.get_sender_ip(email_raw)
    email.ip_info = IpInfo.find_latest_or_create_by_ip(ip) if ip

    email.message_id = email_raw.message_id

    if email_raw.header['List-ID']
      list_id_header_parsed = parse_email_list_id_header(email_raw.header['List-ID'])
      email.list_name = list_id_header_parsed[:name]
      email.list_id = list_id_header_parsed[:id]
    end

    email.date = email_raw.date

    froms_parsed = parse_email_address_field(email_raw, :from)
    if froms_parsed.length > 0
      email.from_name, email.from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]
    end

    senders_parsed = parse_email_address_field(email_raw, :sender)
    if senders_parsed.length > 0
      email.sender_name, email.sender_address = senders_parsed[0][:display_name], senders_parsed[0][:address]
    end

    reply_tos_parsed = parse_email_address_field(email_raw, :reply_to)
    if reply_tos_parsed.length > 0
      email.reply_to_name, email.reply_to_address = reply_tos_parsed[0][:display_name], reply_tos_parsed[0][:address]
    end

    email.tos = email_raw.to.join('; ') if !email_raw.to.blank?
    email.ccs = email_raw.cc.join('; ') if !email_raw.cc.blank?
    email.bccs = email_raw.bcc.join('; ') if !email_raw.bcc.blank?
    email.subject = email_raw.subject.nil? ? '' : email_raw.subject

    email.text_part = email_raw.text_part.decoded.force_utf8(true) if email_raw.text_part
    email.html_part = premailer_html(email_raw.html_part.decoded).force_utf8(true) if email_raw.html_part

    if !email_raw.multipart? && (email_raw.content_type.nil? || email_raw.content_type =~ /text/i)
      email.body_text = premailer_html(email_raw.decoded.force_utf8(true)) if email_raw
    end

    email.has_calendar_attachment = Email.part_has_calendar_attachment(email_raw)

    return email
  end

  def Email.get_sender_ip(email_raw)
    headers = parse_email_headers(email_raw.header.raw_source)
    headers.reverse!

    headers.each do |header|
      next if header.name.nil? || header.value.nil?

      if header.name.downcase == 'x-originating-ip'
        m = header.value.match(/\[(#{$config.ip_regex})\]/)

        if m
          #log_console("FOUND IP #{m[1]} IN X-Originating-IP=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received'
        m = header.value.match(/from.*\[(#{$config.ip_regex})\]/)

        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received-spf'
        m = header.value.match(/client-ip=(#{$config.ip_regex})/)

        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED-SPF=#{header.value}")
          return m[1]
        end
      end
    end

    return nil
  end

  def Email.part_has_calendar_attachment(part)
    return true if part.content_type =~ /text\/calendar|application\/ics/i

    part.parts.each do |current_part|
      return true if Email.part_has_calendar_attachment(current_part)
    end

    return false
  end

  def Email.add_reply_headers(email_raw, email_in_reply_to)
    email_raw.in_reply_to = "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    references_header_string = ''

    reference_message_ids = email_in_reply_to.email_references.order(:position).pluck(:references_message_id)
    if reference_message_ids.length > 0
      log_console("reference_message_ids.length=#{reference_message_ids.length}")

      references_header_string = '<' + reference_message_ids.join("><") + '>'
    elsif email_in_reply_to.email_in_reply_tos.count == 1
      log_console("email_in_reply_tos.count=#{email_in_reply_to.email_in_reply_tos.count}")

      references_header_string =
          '<' + email_in_reply_to.email_in_reply_tos.first.in_reply_to_message_id + '>'
    end

    references_header_string << "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    log_console("references_header_string = #{references_header_string}")

    email_raw.references = references_header_string
  end

  def user
    return self.email_account.user
  end

  def add_references(email_raw)
    return if email_raw.references.nil?

    if email_raw.references.class == String
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => email_raw.references,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      return
    end

    position = 0

    email_raw.references.each do |references_message_id|
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => references_message_id,
                                          :position => position)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end

  def add_in_reply_tos(email_raw)
    return if email_raw.in_reply_to.nil?

    if email_raw.in_reply_to.class == String
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => email_raw.in_reply_to,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      return
    end

    position = 0

    email_raw.in_reply_to.each do |in_reply_to_message_id|
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => in_reply_to_message_id,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end

  def add_attachments(email_raw)
    if !email_raw.multipart? && email_raw.content_type && email_raw.content_type !~ /text/i
      self.add_attachment(email_raw)
    end

    email_raw.attachments.each do |attachment|
      self.add_attachment(attachment)
    end
  end

  def add_attachment(attachment)
    email_attachment = EmailAttachment.new

    email_attachment.email = self
    email_attachment.filename = attachment.filename
    email_attachment.content_type = attachment.content_type.split(';')[0].downcase.strip if attachment.content_type

    decoded_data = attachment.decoded
    email_attachment.file_size = decoded_data.length
    email_attachment.sha256_hex_digest = Digest::SHA256.hexdigest(decoded_data)

    email_attachment.save!
  end

  def add_recipients(email_raw)
    tos_parsed = parse_email_address_field(email_raw, :to)
    tos_parsed.each { |to| self.add_recipient(to[:display_name], to[:address], EmailRecipient.recipient_types[:to]) }

    ccs_parsed = parse_email_address_field(email_raw, :cc)
    ccs_parsed.each { |cc| self.add_recipient(cc[:display_name], cc[:address], EmailRecipient.recipient_types[:cc]) }

    bccs_parsed = parse_email_address_field(email_raw, :bcc)
    bccs_parsed.each { |bcc| self.add_recipient(bcc[:display_name], bcc[:address], EmailRecipient.recipient_types[:bcc]) }
  end

  def add_recipient(name, email_address, recipient_type)
    person = nil
    while person.nil?
      begin
        person = Person.find_or_create_by!(:email_account => self.email_account,
                                           :email_address => cleanse_email(email_address))
      rescue ActiveRecord::RecordNotUnique
      end
    end

    person.name = name
    person.save!

    email_recipient = nil
    while email_recipient.nil?
      begin
        email_recipient = EmailRecipient.find_or_create_by!(:email => self, :person => person,
                                                            :recipient_type => recipient_type)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def run_bounce_back()
    return if !self.bounce_back

    do_bounce_back = false

    if self.bounce_back_type == Email.bounce_back_types[:always]
      log_console('bounce back ALWAYS!!')

      do_bounce_back = true
    elsif self.bounce_back_type == Email.bounce_back_types[:no_reply]
      log_console('bounce back NO reply!!')

      if EmailInReplyTo.where(:email => self.email_account.emails, :in_reply_to_message_id => self.message_id).count == 0
        log_console('NO reply found!! doing bounce!!')

        do_bounce_back = true
      end
    elsif self.bounce_back_type == Email.bounce_back_types[:not_opened]
      log_console('bounce back UNOPENED!!')

      if self.email_tracker_views.count == 0
        log_console('NO views found!! doing bounce!!')

        do_bounce_back = true
      end
    end

    self.email_account.apply_label_to_email(self, label_id: 'INBOX') if do_bounce_back
  end

  def get_attachments_from_gmail_data(gmail_client, parts_data, attachments = [])
    return attachments if parts_data.nil?

    gmail_client = self.email_account.gmail_client if gmail_client.nil?

    parts_data.each do |part|
      get_attachments_from_gmail_data(gmail_client, part['parts'], attachments)

      log_exception() do
        retry_block do
          if !part['filename'].blank? && part['body']
            email_attachment = EmailAttachment.new

            email_attachment.email = self
            email_attachment.filename = part['filename']
            email_attachment.mime_type = part['mimeType']

            if part['headers']
              part['headers'].each do |header|
                name = header['name'].downcase
                value = header['value']

                if name == 'content-type'
                  email_attachment.content_type = value.split(';')[0].downcase.strip
                elsif name == 'content-disposition'
                  email_attachment.content_disposition = value
                end
              end
            end

            body = part['body']

            if body['data']
              data = Base64.decode64(body['data'])
              email_attachment.file_size = data.length
              email_attachment.sha256_hex_digest = Digest::SHA256.hexdigest(data)
            else
              email_attachment.gmail_attachment_id = body['attachmentId']
              attachment_json = gmail_client.attachments_get('me', self.uid, email_attachment.gmail_attachment_id)

              data = Base64.urlsafe_decode64(attachment_json['data'])
              email_attachment.file_size = data.length
              email_attachment.sha256_hex_digest = Digest::SHA256.hexdigest(data)
            end

            email_attachment.s3_key = s3_get_new_key()

            file = Tempfile.new('turing')
            file.binmode
            file.write(data)
            file.close()

            file_info = {:content_type => email_attachment.content_type,
                         :content_disposition => email_attachment.content_disposition,
                         :s3_key => email_attachment.s3_key,
                         :file => file
            }
            s3_write_file(file_info)

            FileUtils.remove_entry_secure(file.path)

            attachments.push(email_attachment)
          end
        end
      end
    end

    return attachments
  end

  def upload_attachments
    email_account = self.email_account
    gmail_client = email_account.gmail_client

    new_email_attachments = []

    retry_block do
      gmail_data = gmail_client.messages_get('me', self.uid, format: 'full')
      new_email_attachments = self.get_attachments_from_gmail_data(gmail_client, gmail_data['payload']['parts'])
    end

    self.email_attachments.each do |old_attachment|
      new_email_attachments.each do |new_attachment|
        if old_attachment.sha256_hex_digest == new_attachment.sha256_hex_digest ||
           (old_attachment.sha256_hex_digest.nil? &&
            old_attachment.filename == new_attachment.filename &&
            old_attachment.file_size == new_attachment.file_size)
          new_attachment.uid = old_attachment.uid
        end
      end
    end

    ActiveRecord::Base.transaction do
      self.email_attachments.destroy_all()
      new_email_attachments.each { |email_attachment| email_attachment.save!() }
    end

    self.attachments_uploaded = true
    self.save!()
  end
end
