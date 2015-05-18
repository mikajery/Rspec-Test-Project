$config.action_mailer.delivery_method = :smtp
$config.action_mailer.perform_deliveries = true
$config.action_mailer.raise_delivery_errors = true

$config.action_mailer.default_options = {
  :from => $config.no_reply_email_full
}

$config.action_mailer.default_url_options = {
  :host => $config.http_host
}

# cdn
# $config.action_mailer.asset_host = $config.action_controller.asset_host

if !Rails.env.development?
  $config.action_mailer.default_url_options[:protocol] = 'https' if !Rails.env.production?

  #$config.action_mailer.asset_host = "https://#{$config.action_mailer.asset_host}"
end

$config.action_mailer.smtp_settings = {
  :address              => $config.mailgun_smtp_server,
  :port                 => 587,
  :domain               => $config.smtp_helo_domain,
  :user_name            => $config.mailgun_smtp_username,
  :password             => $config.mailgun_smtp_password,
  :authentication       => :plain,
  :enable_starttls      => true
}

=begin
class ActionMailerInterceptor
  def self.delivering_email(email)
    email.header['X-MC-Important'] = 'true' if !email.header.has_key?('X-MC-Important') 
  end
end

ActionMailer::Base.register_interceptor(ActionMailerInterceptor)
=end
