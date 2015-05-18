class EmailTrackerRecipientsController < ApplicationController
  before_action :set_cache_control

  def confirmation
    email_tracker_recipient_uid = params[:email_tracker_recipient_uid]
    email_tracker_recipient = EmailTrackerRecipient.find_by_uid(email_tracker_recipient_uid)

    if email_tracker_recipient
      email_tracker_view = EmailTrackerView.new
      email_tracker_view.email_tracker_recipient = email_tracker_recipient
      
      email_tracker_view.ip_address = request.headers['X-Forwarded-For'] || request.remote_ip
      email_tracker_view.user_agent = request.user_agent
      
      email_tracker_view.save!
    end
  ensure
    redirect_to view_context.image_url('confirmation.gif'), :status => 302
  end


  private
    def set_cache_control
      response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
      response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
      response.headers['Expires'] = '0' # Proxies.
    end
end
