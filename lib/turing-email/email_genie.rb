# TODO write tests
class EmailGenie
  LISTS = { '<sales@optimizely.com' => 'Sales',
            '<press@optimizely.com' => 'Press',
            '<marketing@optimizely.com' => 'Marketing',
            '<visible-changes@optimizely.com' => 'Visible Changes',
            '<events@optimizely.com' => 'Events',
            '<archive@optimizely.com' => 'Archive',
            '<team@optimizely.com' => 'Team',
            '<team-sf@optimizely.com' => 'Team (SF)',
            '<team-ams@optimizely.com' => 'Team (AMS)',
            '<rocketship@optimizely.com' => 'Rocketship' }

  def EmailGenie.send_user_report_email(user, demo = false)
    return if user.gmail_accounts.first.nil?

    inbox_label = user.gmail_accounts.first.inbox_folder
    if inbox_label
      where_clause = demo ? '' :
                            ['date < ? AND date > ?', Time.now - 7.hours, Time.now - 7.hours - 24.hours]

      num_important_emails = inbox_label.emails.where(where_clause).order(:date => :desc).count
      important_emails = inbox_label.emails.where(where_clause).order(:date => :desc).limit(100)
    else
      num_important_emails = 0
      important_emails = []
    end

    log_console("FOUND #{important_emails.count} IMPORTANT emails")

    num_auto_filed_emails = user.emails.where(:auto_filed => true, :auto_filed_reported => false).order(:date => :desc).count
    auto_filed_emails = user.emails.where(:auto_filed => true, :auto_filed_reported => false).order(:date => :desc).limit(100)
    log_console("FOUND #{auto_filed_emails.count} AUTO FILED emails")

    GenieMailer.user_report_email(user,
                                  num_important_emails, important_emails,
                                  num_auto_filed_emails, auto_filed_emails).deliver()

    user.emails.where(:auto_filed => true, :auto_filed_reported => false).update_all(:auto_filed_reported => true)
  end

  def EmailGenie.new_gmail_batch_request()
    Google::APIClient::BatchRequest.new() do |result|
      if result.error?
        log_console("AHHHHHHHH batch error #{result.response.status}")
        log_console(result.to_yaml())
      end
    end
  end

  def EmailGenie.send_report_if_jobs_done(gmail_account, demo, job_ids)
    num_jobs_pending = Delayed::Job.where(:id => job_ids, :failed_at => nil).count

    if num_jobs_pending == 0
      log_console("#{gmail_account.email} brain DONE!! sending report")
      
      if !gmail_account.user.has_genie_report_ran
        log_console("#{gmail_account.user.email} FIRST report - sending alert and queuing full sync")
        
        GenieMailer.email_synced_email(gmail_account.user).deliver()
        
        gmail_account.last_history_id_synced = nil
        gmail_account.save!

        gmail_account.delay(num_dynos: GmailAccount::NUM_SYNC_DYNOS).sync_email()
      end
  
      EmailGenie.send_user_report_email(gmail_account.user, demo)
    else
      log_console("#{gmail_account.email} brain jobs left=#{num_jobs_pending}!!")

      EmailGenie.delay({run_at: 1.minute.from_now}, num_dynos: GmailAccount::NUM_SYNC_DYNOS).send_report_if_jobs_done(gmail_account, demo, job_ids)
    end
  end
    
  def EmailGenie.run_brain_and_report(gmail_account, demo = false)
    job_ids = EmailGenie.process_gmail_account(gmail_account, demo)
    EmailGenie.delay(num_dynos: GmailAccount::NUM_SYNC_DYNOS).send_report_if_jobs_done(gmail_account, demo, job_ids)
  end
  
  def EmailGenie.process_gmail_account(gmail_account, demo = false)
    inbox_label = gmail_account.inbox_folder
    if inbox_label.nil?
      log_console("#{gmail_account.email}: process_gmail_account exiting! NO inbox!!")
      return
    end

    log_console("#{gmail_account.email}: STARTING process_gmail_account!")
    
    HerokuTools::HerokuTools.scale_dynos('worker', GmailAccount::NUM_SYNC_DYNOS)
    
    job_ids = []

    top_lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user, limit: 10).transpose()[0]
    
    where_clause = demo ? '' : ['date < ?', Time.now - 7.hours]

    inbox_label.emails.where(where_clause).select(:id).find_in_batches(:batch_size => 250) do |emails|
      log_console("QUEUEING #{emails.length} emails for brain!")

      email_ids = emails.map { |email| email.id }
      
      job = EmailGenie.delay(heroku_scale: false).process_emails(gmail_account, top_lists_email_daily_average, email_ids)
      job_ids.push(job.id)
    end

    log_console("#{gmail_account.email}: process_gmail_account DONE with #{job_ids.length} jobs!")
    
    return job_ids
  end
  
  def EmailGenie.process_emails(gmail_account, top_lists_email_daily_average, email_ids)
    log_console("#{gmail_account.email}: process_emails #{email_ids.length} emails!")
    
    inbox_label = gmail_account.inbox_folder
    sent_label = gmail_account.sent_folder

    if $config.gmail_live
      batch_request = EmailGenie.new_gmail_batch_request()
      gmail_client = gmail_account.gmail_client
      batch_empty = true
    end

    auto_cleaner_enabled = gmail_account.user.user_configuration.auto_cleaner_enabled
    
    Email.where(:id => email_ids).find_each do |email|
      if EmailGenie.email_is_unimportant(email, sent_label: sent_label)
        gmail_label, call = EmailGenie.auto_file(email, inbox_label, sent_label: sent_label,
                                                 top_lists_email_daily_average: top_lists_email_daily_average,
                                                 batch_request: true, gmail_client: gmail_client,
                                                 auto_cleaner_enabled: auto_cleaner_enabled)
  
        if $config.gmail_live && call
          batch_request.add(call)
          batch_empty = false
  
          if batch_request.calls.length == 5
            gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
            batch_request = EmailGenie.new_gmail_batch_request()
            batch_empty = true
            
            sleep(1)
          end
        end
      end
    end

    if !batch_empty && $config.gmail_live
      gmail_account.google_o_auth2_token.api_client.execute!(batch_request)
    end

    log_console("#{gmail_account.email}: process_emails DONE!")
  end

  def EmailGenie.is_no_reply_address(address)
    return (address =~ /.*no-?reply.*@.*/) != nil
  end
  
  def EmailGenie.is_no_reply_email(email)
    return EmailGenie.is_no_reply_address(email.reply_to_address) || EmailGenie.is_no_reply_address(email.from_address)
  end
  
  def EmailGenie.is_calendar_email(email)
    return email.from_address == 'calendar-notification@google.com' ||
           email.sender_address == 'calendar-notification@google.com' ||
           email.has_calendar_attachment
  end
  
  def EmailGenie.is_email_note_to_self(email)
    return email.from_address =~ /^(#{email.user.email}|#{email.email_account.email})$/i &&
           email.email_recipients.count == 1 &&
           email.email_recipients[0].person.email_address =~ /^(#{email.user.email}|#{email.email_account.email})$/i
  end
  
  def EmailGenie.is_automatic_reply_email(email)
    return email.subject && email.subject =~ /^(Automatic Reply|Out of Office)/i
  end

  def EmailGenie.is_unimportant_list_email(email)
    return email.list_id && email.tos && email.tos.downcase !~ /#{email.email_account.email}/
  end
  
  def EmailGenie.is_completed_conversation_email(email, sent_folder = nil)
    return sent_folder &&
           EmailInReplyTo.find_by(:email => sent_folder.emails, :in_reply_to_message_id => email.message_id)
  end
  
  def EmailGenie.is_unimportant_group_email(email)
    return email.email_recipients.count >= 5
  end

  def EmailGenie.email_is_unimportant(email, sent_label: nil)
    email.user.genie_rules.each do |genie_rule|
      return false if genie_rule.from_address && genie_rule.from_address = email.from_address
      return false if genie_rule.to_address && email.email_recipients.joins(:person).pluck(:email_address).include?(genie_rule.to_address)
      return false if genie_rule.subject && email.subject =~ /.*#{genie_rule.subject}.*/i
      return false if genie_rule.list_id && email.list_id == genie_rule.list_id
    end
    
    if EmailGenie.is_calendar_email(email)
      log_console("UNIMPORTANT => Calendar!")
      return true
    elsif EmailGenie.is_email_note_to_self(email)
      log_console("UNIMPORTANT => email.from_address = #{email.from_address} email.tos = #{email.tos}")
      return true
    elsif EmailGenie.is_automatic_reply_email(email)
      log_console("UNIMPORTANT => subject = #{email.subject}")
      return true
    elsif EmailGenie.is_unimportant_list_email(email)
      log_console("UNIMPORTANT => list_id = #{email.list_id}")
      return true
    elsif EmailGenie.is_completed_conversation_email(email, sent_label)
      log_console("UNIMPORTANT => Email IS replied to!")
      return true
    elsif EmailGenie.is_unimportant_group_email(email)
      log_console("UNIMPORTANT => GROUP EMAIL! email_recipients.count = #{email.email_recipients.count}")
      return true
    elsif EmailGenie.is_no_reply_email(email)
      log_console("UNIMPORTANT => NOREPLY = #{email.reply_to_address} #{email.from_address}")
      return true
    elsif sent_label
      reply_address = email.reply_to_address ? email.reply_to_address : email.from_address

      num_emails_to_address = sent_label.emails.where('tos ILIKE ?', "%#{reply_address}%").count
      num_emails_from_address = email.user.emails.where("from_address=? OR reply_to_address=?",
                                                        reply_address, reply_address).count

      ratio = num_emails_to_address / num_emails_from_address.to_f()
      if ratio < 0.1
        log_console("UNIMPORTANT => ratio = #{ratio} with reply_address = #{reply_address}!")
        return true
      end
    end

    return false
  end

  def EmailGenie.auto_file(email, inbox_folder, sent_label: nil, top_lists_email_daily_average: nil,
                           batch_request: false, gmail_client: nil, auto_cleaner_enabled: false)
    log_console("AUTO FILING! #{email.uid}")

    folder_name = nil
    if EmailGenie.is_calendar_email(email)
      folder_name = 'Unimportant/Calendar'
    elsif EmailGenie.is_email_note_to_self(email)
      folder_name = 'Unimportant/Notes to Self'
    elsif EmailGenie.is_automatic_reply_email(email)
      folder_name = 'Unimportant/Automatic Replies'
    elsif EmailGenie.is_unimportant_list_email(email)
      log_console("Found list_id=#{email.list_id}")

      gmail_label, call = 
          EmailGenie.auto_file_list_email(email, top_lists_email_daily_average: top_lists_email_daily_average,
                                          batch_request: batch_request,
                                          gmail_client: gmail_client,
                                          auto_cleaner_enabled: auto_cleaner_enabled)
    elsif EmailGenie.is_completed_conversation_email(email, sent_label)
      folder_name = 'Unimportant/Completed Conversations'
    elsif EmailGenie.is_unimportant_group_email(email)
      folder_name =  'Unimportant/Group Conversations'
    else
      folder_name = 'Unimportant'
    end

    if folder_name
      if auto_cleaner_enabled
        gmail_label, call =
            email.email_account.move_email_to_folder(email, folder_name: folder_name,
                                                     set_auto_filed_folder: true,
                                                     batch_request: batch_request,
                                                     gmail_client: gmail_client)
        email.auto_filed = true
      else
        email.auto_file_folder_name = folder_name
      end
    end

    email.save!
    
    return gmail_label, call
  end
  
  def EmailGenie.auto_file_list_email(email, top_lists_email_daily_average: nil,
                                      batch_request: false, gmail_client: nil, auto_cleaner_enabled: false)
    subfolder = email.list_name
    subfolder = email.list_id if subfolder.nil?
    
    if EmailGenie::LISTS.keys.include?(email.list_id.downcase)
      folder_name = EmailGenie::LISTS[email.list_id.downcase]
    elsif email.from_address == 'notifications@github.com'
      folder_name = "GitHub/#{subfolder}"
    elsif top_lists_email_daily_average.include?(email.list_id)
      folder_name = "List Emails/#{subfolder}"
    else
      folder_name = 'List Emails'
    end

    if auto_cleaner_enabled
      gmail_label, call =
          email.email_account.move_email_to_folder(email, folder_name: folder_name,
                                                   set_auto_filed_folder: true,
                                                   batch_request: batch_request,
                                                   gmail_client: gmail_client)
      email.auto_filed = true
    else
      email.auto_file_folder_name = folder_name
    end

    return gmail_label, call
  end
end
