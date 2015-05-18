module SessionsHelper
  def user_signin_attempt(email, password, api = false)
    user = User.find_by_email(email)

    if user
      if user.login_attempt_count >= $config.max_login_attempts
        if !api
          flash[:danger] = 'Your account has been locked to protect your security. Please reset your password.'
          redirect_to reset_password_url
        else
          render :status => $config.http_errors[:account_locked][:status_code],
                 :json => $config.http_errors[:account_locked][:description]
        end

        return
      elsif user.authenticate(password)
        sign_in user

        if !api
          redirect_back_or root_path
        else
          @user = user
          render 'api/v1/users/show'
        end

        return
      else
        User.increment_counter(:login_attempt_count, user.id)
      end
    end

    if !api
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    else
      render :json => 'Invalid email/password combination',
             :status => 401
    end
  end

  def sign_in(user)
    auth_key = UserAuthKey.new_key
    encrypted_auth_key = UserAuthKey.secure_hash(auth_key)

    user_auth_key = UserAuthKey.new()
    user_auth_key.user = user
    user_auth_key.encrypted_auth_key = encrypted_auth_key
    user_auth_key.save!

    cookies.permanent[:auth_key] = auth_key
    user.update_attribute(:login_attempt_count, 0)

    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    return if cookies[:auth_key].nil?
    return @current_user if @current_user

    encrypted_auth_key  = UserAuthKey.secure_hash(cookies[:auth_key])
    user_auth_key = UserAuthKey.cached_find_by_encrypted_auth_key(encrypted_auth_key)
    @current_user = User.cached_find(user_auth_key.user_id) if user_auth_key

    return @current_user
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user(api = false)
    unless signed_in?
      if api
        render :json => 'Not signed in.', :status => 401
      else
        store_location
        redirect_to signin_url, flash: {:warning => 'Please sign in.'}
      end
    end
  end

  def correct_email_account
    @email_account = current_user.gmail_accounts.first

    if @email_account.nil?
      render :status => $config.http_errors[:email_account_not_found][:status_code],
             :json => $config.http_errors[:email_account_not_found][:description]
      return
    end
  end

  def sign_out
    auth_key = cookies[:auth_key]
    user_auth_key = UserAuthKey.find_by(:user => current_user,
                                        :encrypted_auth_key => UserAuthKey.secure_hash(auth_key)) if auth_key
    user_auth_key.destroy() if user_auth_key

    cookies.delete(:auth_key)
    self.current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
end
