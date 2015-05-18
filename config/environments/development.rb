Rails.application.configure do
  config.heroku_app_name = 'turing-email-dev'

  config.domain = "#{ENV.has_key?('DOMAIN') ? ENV['DOMAIN'] : 'localhost'}"
  config.http_port = "#{ENV.has_key?('HTTP_PORT') ? ENV['HTTP_PORT'] : '4000'}"
  config.http_host = config.domain
  config.http_host += ":#{config.http_port}" if config.http_port != '80'

  config.s3_bucket = 'dev.turingemail.com'

  config.smtp_helo_domain = 'localhost'

  config.url = "http://#{config.http_host}"
  config.api_url = "http://#{config.http_host}"

  config.mailgun_domain = 'dev.turingemail.com'

  config.google_client_id = '900985518357-chpj6f40dertjuam39gn8i0bienk8v24.apps.googleusercontent.com'
  config.google_secret = 'NzWBuq2I7Ci04vrElrFE7LQE'

  config.mailgun_api_key = 'key-77f40750a8aa1f3b76d92bccba4e4e59'
  config.mailgun_public_api_key = 'pubkey-9e325d313b41af58399aec7ef0084ba9'
  config.mailgun_smtp_username = 'postmaster@dev.turingemail.com'
  config.mailgun_smtp_password = '5ced9285272c96d6e49ec2105e087bcf'

  config.heroku_api_key = ''

  config.google_analytics_key = 'UA-55892559-2'

  config.aws_access_key_id = 'AKIAI3XHDPLQ4E5ECCZQ'
  config.aws_secret_access_key = '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'

  config.log_level = :info if !ENV.has_key?('SQL_DEBUG')

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    # Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
