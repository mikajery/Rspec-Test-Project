class ApplicationController < ActionController::Base
  force_ssl if ENV['FORCE_SSL'].present?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include ApplicationHelper
  include GmailAccountsHelper

  #before_action :authenticate
  before_filter :miniprofiler

  rescue_from(Exception, :with => :render_exception) unless $config.consider_all_requests_local

  # :nocov:
  def render_exception(ex)
    log_email_exception(ex)
    raise ex
  end

  protected
  def skip_basic_auth?
    return Rails.env.development? || Rails.env.test?
  end

  def public_path?
    return false
  end

  def authenticate
    return if skip_basic_auth?() || public_path?()

    authenticate_or_request_with_http_basic do |username, password|
      username == 'turing' && password == 'email2'
    end
  end

  def admin_user?
    redirect_to(root_url) unless current_user && current_user.admin
  end

  def miniprofiler
    local_mini_profiler_flag = false
    if current_user && (current_user.admin || Rails.env.beta?) && local_mini_profiler_flag
      Rack::MiniProfiler.authorize_request
    end
  end
  # :nocov:
end
