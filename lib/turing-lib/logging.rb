class Exception
  def log_message
    return "#{self.class}: #{self.message}\r\n\r\n#{self.backtrace}"
  end
end

def log_email(subject, text = ' ', to_console = true, to = $config.logs_email, delayed_send = false)
  log_exception(false) do
    text = ' ' if text == '' || text.nil?

    log_exception(false) do
      r = RestClient
      r = r.delay if delayed_send

      r.post "#{$config.mailgun_api_url}/messages",
             :from => $config.logs_email_full,
             :to => to,
             :subject => "#{$config.service_name} (#{Rails.env}) - #{subject}",
             :text => text
    end

    if to_console
      console_output = subject.dup
      console_output << "\r\n\r\n#{text}" if text != ' '
      log_console(console_output)
    end
  end
end

def log_email_exception(ex, to_console = true)
  log_email(ex.message, ex.log_message, to_console)
end

def log_console(message, job = nil)
  return job.log_console_wrapper(message) if job

  if Rails.env.test?
    puts(message)
  else
    Rails.logger.info(message)
  end
rescue Exception => ex
  log_email('log_console ERROR!!', "#{ex.log_message}\r\n\r\n#{message}", false)
end

def log_console_exception(ex)
  log_console(ex.log_message)
end

def log_exception(email = true)
  yield
rescue Exception => ex
  log_console_exception(ex)

  if email
    subject = "log_exception - #{ex.message}"
    body = ex.log_message
    log_email(subject, body)
  end
end
