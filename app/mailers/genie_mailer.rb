class GenieMailer < ActionMailer::Base
  layout 'email'

  def user_report_email(user,
                        num_important_emails, important_emails,
                        num_auto_filed_emails, auto_filed_emails)
    @user = user

    @num_important_emails = num_important_emails
    @important_emails = important_emails

    @num_auto_filed_emails = num_auto_filed_emails
    @auto_filed_emails = auto_filed_emails

    email = mail(to: user.email, subject: "#{$config.service_name} - Your daily Brain Report!")
    #email.header['X-MC-Important'] = 'true'
    #email.header['X-MC-Tags'] = 'welcome_email'

    if !user.has_genie_report_ran
      user.has_genie_report_ran = true
      user.save!
    end

    return email
  rescue Exception => ex
    log_email('GenieMailer.user_report_email FAILED!', "#{user.id} #{user.email}\r\n\r\n#{ex.log_message}")
  end
  
  def email_synced_email(user)
    @user = user

    email = mail(to: user.email, subject: "#{$config.service_name} - Email Ready!")

    return email
  rescue Exception => ex
    log_email('GenieMailer.email_synced_email FAILED!', "#{user.id} #{user.email}\r\n\r\n#{ex.log_message}")
  end
end
