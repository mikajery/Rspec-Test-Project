class GmailAccountsController < ApplicationController
  def get_api_client(code)
    o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)
    o_auth2_base_client.redirect_uri = gmail_oauth2_callback_url
    o_auth2_base_client.code = code
    o_auth2_base_client.fetch_access_token!()

    # don't save because no GmailAccount yet to set to required google_api attribute.
    google_o_auth2_token = GoogleOAuth2Token.new()
    google_o_auth2_token.update(o_auth2_base_client, false)
    
    return google_o_auth2_token, google_o_auth2_token.api_client(), o_auth2_base_client
  end

  def o_auth2_callback
    error = params[:error]
    code = params[:code]

    if error || code.nil?
      if error == 'access_denied'
        flash[:danger] = I18n.t('gmail.access_not_granted')
      else
        flash[:danger] = I18n.t(:error_message_default).html_safe
      end

      redirect_to(root_url)
    else
      new_user = false
      
      token = nil
      gmail_account = nil
      created_gmail_account = false

      begin
        sign_out() if current_user
        
        google_o_auth2_token, api_client, o_auth2_base_client = self.get_api_client(code)
        
        userinfo_data = GmailAccount.get_userinfo(api_client)
        gmail_account = GmailAccount.find_by_google_id(userinfo_data['id'])
        
        if gmail_account
          log_console("FOUND gmail_account=#{gmail_account.email}")
          user = gmail_account.user
          if user.profile_picture != userinfo_data['picture']
            user.profile_picture = userinfo_data['picture']
            user.save!
          end

          if google_o_auth2_token.refresh_token.blank?
            begin
              gmail_account.google_o_auth2_token.refresh(nil, true)
            rescue Signet::AuthorizationError
              log_console("BAD!!! refresh token - redirecting to gmail login!!!")
              redirect_to gmail_o_auth2_url(true)
              return
            end
          end
          
          gmail_account.google_o_auth2_token.update(o_auth2_base_client, true)
        else
          log_console("NOT FOUND gmail_account!!!")
          new_user = true
          
          if google_o_auth2_token.refresh_token.blank?
            log_console("NO refresh token - redirecting to gmail login!!!")
            redirect_to gmail_o_auth2_url(true)
            return
          end
          
          user = User.new()
          user.email           = userinfo_data['email'].downcase
          user.profile_picture = userinfo_data['picture']
          user.name            = userinfo_data['name']
          user.given_name      = userinfo_data['given_name']
          user.family_name     = userinfo_data['family_name']
          user.password        = user.password_confirmation = SecureRandom.uuid()
          user.save!

          created_gmail_account = true

          gmail_account = GmailAccount.new()
          gmail_account.user = user

          user.with_lock do
            gmail_account.refresh_user_info(api_client)

            google_o_auth2_token.google_api = gmail_account
            google_o_auth2_token.save!

            gmail_account.google_o_auth2_token = google_o_auth2_token
            gmail_account.save!
          end

          UserMailer.delay.welcome_email(user)
        end
        
        sign_in(user)

        gmail_account.delay.sync_email(labelIds: "INBOX") if created_gmail_account

        #flash[:success] = I18n.t('gmail.authenticated')
      rescue Exception => ex
        log_exception(false) { gmail_account.destroy! if created_gmail_account && gmail_account }
        log_exception(false) { token.destroy! if token }

        flash[:danger] = I18n.t(:error_message_default).html_safe
        log_email_exception(ex)
      end

      if new_user
        redirect_to(mail_url + '#welcome_tour')
      else
        redirect_to(mail_url)
      end
    end
  end

  def o_auth2_remove
    current_user.with_lock do
      gmail_account = current_user.gmail_accounts.first
      if gmail_account
        gmail_account.delete_o_auth2_token()
        gmail_account.last_history_id_synced = nil
        gmail_account.save!
      end
    end

    flash[:success] = flash[:success] = I18n.t('gmail.unlinked')
    redirect_to(root_url)
  end
end
