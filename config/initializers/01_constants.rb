$config = Rails.configuration
$url_helpers = Rails.application.routes.url_helpers
$helpers = ActionController::Base.helpers

# constants

ERROR = -1
OK = 1

# keys

$config.google_client_id ||= ENV['GOOGLE_CLIENT_ID']
$config.google_secret ||= ENV['GOOGLE_SECRET']

$config.mailgun_api_key ||= ENV['MAILGUN_API_KEY']
$config.mailgun_public_api_key ||= ENV['MAILGUN_PUBLIC_API_KEY']
$config.mailgun_smtp_username ||= ENV['MAILGUN_SMTP_USERNAME']
$config.mailgun_smtp_password ||= ENV['MAILGUN_SMTP_PASSWORD']

$config.heroku_api_key ||= ENV['HEROKU_API_KEY']

$config.google_analytics_key ||= ENV['GOOGLE_ANALYTICS_KEY']

$config.aws_access_key_id ||= ENV['AWS_ACCESS_KEY_ID']
$config.aws_secret_access_key ||= ENV['AWS_SECRET_ACCESS_KEY']

# http errors

$config.http_errors = {
    :already_have_account => {:status_code => 600, :description => 'You already have an account!'},
    :invalid_email_or_password => {:status_code => 601, :description => 'Invalid email or password.'},
    :email_in_use => {:status_code => 602, :description => 'Email in use.'},
    :account_locked => {:status_code => 603, :description => 'Account locked.'},

    :email_folder_not_found => {:status_code => 610, :description => 'Email folder not found.'},

    :email_not_found => {:status_code => 620, :description => 'Email not found.'},
    :email_thread_not_found => {:status_code => 630, :description => 'Email Thread not found.'},

    :genie_rule_not_found => {:status_code => 640, :description => 'Genie Rule not found.'},
    :email_rule_not_found => {:status_code => 650, :description => 'Email Rule not found.'},

    :email_account_not_found => {:status_code => 660, :description => 'Email Account not found.'},
    :app_not_found => {:status_code => 670, :description => 'App not found.'},

    :email_template_not_found => {:status_code => 680, :description => 'Email template not found.'},
    :email_template_name_in_use => {:status_code => 681, :description => 'Email template name in use.'},

    :email_attachment_not_ready => {:status_code => 690, :description => 'Email attachment not ready.'},
    :email_attachment_not_found => {:status_code => 691, :description => 'Email attachment not found.'},

    :email_signature_not_found => {:status_code => 700, :description => 'Email signature not found.'},
    :email_signature_name_in_use => {:status_code => 701, :description => 'Email signature name in use.'},

    :email_template_category_not_found => {:status_code => 710, :description => 'Email template category not found.'},
    :email_template_category_name_in_use => {:status_code => 711, :description => 'Email template category name in use.'},

    :user_update_error => {:status_code => 801, :description => 'Error updating user.'}
}

# aws config

AWS.config(:access_key_id => $config.aws_access_key_id,
           :secret_access_key => $config.aws_secret_access_key)

$config.s3_key_length = 256
$config.s3_base_url = "https://s3.amazonaws.com/#{$config.s3_bucket}"

# globals

$config.gmail_live = true

$config.company_name = 'Turing Technology, Inc.'
$config.service_name = 'Turing Email'
$config.service_name_short = 'Turing'

$config.default_time_zone = 'Pacific Time (US & Canada)'

$config.smtp_helo_domain = $config.domain

$config.email_domain = 'turinginc.com'

#$config.password_validation_regex = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}\z/
$config.email_validation_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
$config.ip_regex = /\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+/

$config.support_email = "support@#{$config.email_domain}"
$config.logs_email = "logs@#{$config.email_domain}"
$config.no_reply_email = "noreply@#{$config.email_domain}"
$config.genie_email = "genie@#{$config.email_domain}"

$config.support_email_name = "#{$config.service_name} (Support)"
$config.logs_email_name = "#{$config.service_name} Logs (#{Rails.env})"
$config.no_reply_email_name = $config.service_name
$config.genie_email_name = 'Turing'

$config.support_email_full = "#{$config.support_email_name} <#{$config.support_email}>"
$config.logs_email_full = "#{$config.logs_email_name} <#{$config.logs_email}>"
$config.no_reply_email_full = "#{$config.no_reply_email_name} <#{$config.no_reply_email}>"
$config.genie_email_full = "#{$config.genie_email_name} <#{$config.genie_email}>"

$config.max_login_attempts = 5

$config.volume_report_date_format = '%-m/%-d/%Y'

# rule recommendations
$config.recommended_rules_average_daily_list_volume = 5

# mailgun
$config.mailgun_smtp_server = 'smtp.mailgun.org'
$config.mailgun_api_url_base = "https://api:#{$config.mailgun_api_key}@api.mailgun.net/v2"
$config.mailgun_api_url = "#{$config.mailgun_api_url_base}/#{$config.mailgun_domain}"

# Heroku Dynos
#$config.heroku_dynos = ['worker']
$config.heroku_dynos = []

# Delayed Job
$config.dj_queues = ['worker']
$config.dj_queue_alert_size = 100000
$config.dj_queues_heroku_dynos = {
    #'worker' => 'worker'
}
