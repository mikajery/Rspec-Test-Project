class MockSessionsController < ApplicationController
  def new
    if Rails.env.test?
      begin
        sign_out if current_user
        user = User.find(params[:user_id])
        sign_in(user)
      rescue Exception => ex
        log_email_exception(ex)
      end
      redirect_to(mail_url)
    else
      redirect_to(root_url)
    end
  end
end
