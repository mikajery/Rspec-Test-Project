class UserMailer < ActionMailer::Base
  layout 'email'

  def welcome_email(user)
    @user = user

    email = mail(to: user.email, subject: "Welcome to #{$config.service_name}!")

    return email
  rescue Exception => ex
    log_email('UserMailer.welcome_email FAILED!', "#{user.id} #{user.email}\r\n\r\n#{ex.log_message}")
  end
end
