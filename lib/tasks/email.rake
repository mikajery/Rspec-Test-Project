desc 'Sync all email accounts'

task :sync_email, [:labelIds_string] => :environment do |t, args|
  args.with_defaults(:labelIds_string => nil)
  labelIds = nil
  labelIds = args.labelIds_string.split(' ') if args.labelIds_string
  
  GmailAccount.find_each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")
      
      gmail_account.delay.sync_email(labelIds: labelIds)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Sync all email accounts - labels only'

task :sync_labels => :environment do
  GmailAccount.find_each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")

      gmail_account.sync_labels()
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run the genie on all email accounts'

task :email_genie, [:demo] => :environment do |t, args|
  args.with_defaults(:demo => false)
  
  GmailAccount.find_each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")
  
      EmailGenie.process_gmail_account(gmail_account, args.demo)

    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run genie reports for all accounts'

task :email_genie_reports, [:demo] => :environment do |t, args|
  args.with_defaults(:demo => false)
  
  User.find_each do |user|
    begin
      log_console("PROCESSING user #{user.email}")

      EmailGenie.send_user_report_email(user, args.demo)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run brain and report for all accounts'

task :brain_and_report, [:demo] => :environment do |t, args|
  args.with_defaults(:demo => false)

  User.find_each do |user|
    begin
      log_console("PROCESSING user #{user.email}")

      gmail_account = user.gmail_accounts.first
      if gmail_account.nil?
        log_console("SKIPPING #{user.email} no gmail!!!!!!!")
        next
      end
      
      EmailGenie.delay(num_dynos: GmailAccount::NUM_SYNC_DYNOS).run_brain_and_report(gmail_account, args.demo)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Reset the genie for testing purposes'

task :email_genie_reset => :environment do
  User.find_each do |user|
    begin
      emails_auto_filed = user.emails.where(:auto_filed => true)
      log_console("FOUND #{emails_auto_filed.length} AUTO FILED!!")

      EmailFolderMapping.where(:email => emails_auto_filed).destroy_all
      inbox_label = user.gmail_accounts.first.inbox_folder
      
      emails_auto_filed.each do |email|
        begin
          EmailFolderMapping.find_or_create_by!(:email_folder => inbox_label, :email => email,
                                                :folder_email_thread_date => email.email_thread.emails.maximum(:date),
                                                :folder_email_date => email.date,
                                                :folder_email_draft_id => email.draft_id,
                                                :email_thread => email.email_thread)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      
      emails_auto_filed.update_all(:auto_filed => false, :auto_filed_reported => false,
                                   :auto_filed_folder_id => nil, :auto_filed_folder_type => nil)

      user.emails.update_all(:auto_file_folder_name => nil)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Reset the genie report for testing purposes'

task :email_genie_reports_reset => :environment do
  User.find_each do |user|
    begin
      email_ids_auto_filed = user.emails.where(:auto_filed => true).pluck(:id)
      log_console("FOUND #{email_ids_auto_filed.length} AUTO FILED!!")
    
      Email.where(:id => email_ids_auto_filed).update_all(:auto_filed_reported => false)
        
      user.has_genie_report_ran = false
      user.save!
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run email rules'

task :run_email_rules => :environment do
  User.find_each do |user|
    begin
      log_console("PROCESSING account #{user.email}")
      
      user.apply_email_rules_to_folder(user.email_account.inbox_folder)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end
