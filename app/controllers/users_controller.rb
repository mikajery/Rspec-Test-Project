class UsersController < ApplicationController
  before_action :signed_in_user, except: [:new, :create, :reset_password]

  def new
    if signed_in?
      flash[:info] = 'You already have an account!'

      redirect_to root_url
      return
    else
      redirect_to gmail_o_auth2_url(true)
      return
    end
  end

  def create
    if signed_in?
      flash[:info] = 'You already have an account!'

      redirect_to root_url
      return
    else
      @user, success = User.create_from_post(params)

      if success
        sign_in @user

        flash[:success] = "Welcome to #{$config.service_name}!"
        redirect_to root_url
      else
        render 'new' # errors are rendered from @user
      end
    end
  rescue ActiveRecord::RecordNotUnique => unique_violation
    flash.now[:danger] = User.get_unique_violation_error(unique_violation)

    render 'new'
  rescue Exception => ex
    log_email_exception(ex)
    @user.destroy if @user

    flash.now[:danger] = I18n.t(:error_message_default).html_safe
    render 'new'
  end

  def reset_password
  end
end
