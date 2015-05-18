module SpecMisc
  TINY_LIST_SIZE = 3
  SMALL_LIST_SIZE = 5
  MEDIUM_LIST_SIZE = 10
  LARGE_LIST_SIZE = 20

  GMAIL_TEST_EMAIL = 'turingemailtest1@gmail.com'
  MAILINATOR_TEST_EMAIL = 'uexwvt3ei6ojrcbxspwjs8eohfsywasi@mailinator.com'
  GMAIL_TEST_PASSWORD = 'turing102'

  def create_email_thread_emails(email_threads, email_folder: nil, num_emails: SpecMisc::TINY_LIST_SIZE, do_sleep: false)
    emails = []

    email_threads.each do |email_thread|
      if do_sleep
        num_emails.times do
          emails << FactoryGirl.create(:email, :email_thread => email_thread)
          sleep (do_sleep)
        end
      else
        emails += FactoryGirl.create_list(:email, num_emails, :email_thread => email_thread)
      end

      create_email_folder_mappings(email_thread.emails, email_folder) if email_folder
    end

    return emails
  end

  def create_email_folder_mappings(emails, email_folder = nil)
    emails.each do |email|
      properties = { :email => email }
      properties[:email_folder] = email_folder if email_folder
      properties[:email_thread] = email.email_thread if email.email_thread
      FactoryGirl.create(:email_folder_mapping, properties)
    end
  end

  def spec_validate_attributes(expected_attributes, model, model_rendered, expected_attributes_to_skip = [])
    Rails.logger.fatal("in spec")
    expected_attributes = expected_attributes.sort

    keys = model_rendered.keys.sort!
    expect(keys).to eq(expected_attributes)


    model_rendered.each do |key, value|
      next if expected_attributes_to_skip.include?(key)

      if model.respond_to?(key)
        expect(value).to eq(model.send(key))
      else
        expect(value).to eq(model[key])
      end
    end
  end

  def validate_ip_stat(ip_stat, ip_stat_rendered)
    expected_attributes = %w(country_code country_name
                             region_code region_name
                             city zip_code
                             latitude longitude
                             metro_code area_code)
    spec_validate_attributes(expected_attributes, ip_stat, ip_stat_rendered)
  end

  def validate_email_thread(email_thread, email_thread_rendered)
    Rails.logger.fatal("Entered validate_email thread")
    expected_attributes = %w(uid emails emails_count)
    expected_attributes_to_skip = %w(emails emails_count)

    spec_validate_attributes(expected_attributes, email_thread, email_thread_rendered, expected_attributes_to_skip)

    validate_email(email_thread.latest_email, email_thread_rendered['emails'][0])
  end

  def validate_email(email, email_rendered)
    expected_attributes = %w(auto_file_folder_name
                             auto_filed
                             uid draft_id message_id list_id
                             seen snippet date
                             email_attachment_uploads email_attachments
                             from_name from_address
                             sender_name sender_address
                             reply_to_name reply_to_address
                             tos ccs bccs
                             subject
                             html_part text_part body_text
                             folder_ids)

    expected_attributes_to_skip = %w(id date folder_ids)

    Rails.logger.fatal("Entered validate_email")
    spec_validate_attributes(expected_attributes, email, email_rendered, expected_attributes_to_skip)
    expect(email_rendered['date']).to eq(email.date.as_json)

    folder_ids = email.gmail_labels.pluck("label_id").concat(email.imap_folders.pluck("name")).sort()
    expect(email_rendered["folder_ids"].sort()).to eq(folder_ids)
Rails.logger.fatal("Left validate_email")
  end

  def validate_gmail_label(gmail_label, gmail_label_rendered)
    expected_attributes = %w(label_id name
                             message_list_visibility label_list_visibility
                             label_type
                             num_threads num_unread_threads)
    spec_validate_attributes(expected_attributes, gmail_label, gmail_label_rendered)
  end

  def validate_imap_folder(imap_folder, imap_folder_rendered)
    expected_attributes = %w(name)
    spec_validate_attributes(expected_attributes, imap_folder, imap_folder_rendered)
  end

  def validate_ip_info(ip_info, ip_info_rendered)
    expected_attributes = %w(ip
                             country_code country_name
                             region_code region_name
                             city zipcode
                             latitude longitude
                             metro_code area_code)

    expected_attributes_to_skip = %w(ip)
    spec_validate_attributes(expected_attributes, ip_info, ip_info_rendered, expected_attributes_to_skip)

    expect(ip_info_rendered['ip']).to eq(ip_info.ip.to_s)
  end

  def validate_email_rule(email_rule, email_rule_rendered)
    expected_attributes = %w(uid from_address to_address subject list_id destination_folder_name)
    spec_validate_attributes(expected_attributes, email_rule, email_rule_rendered)
  end

  def validate_email_template(email_template, email_template_rendered)
    expected_attributes = %w(uid name text html category_uid)
    spec_validate_attributes(expected_attributes, email_template, email_template_rendered)
  end

  def validate_email_template_category(email_template_category, email_template_category_rendered)
    expected_attributes = %w(uid name email_templates_count created_at)
    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_template_category, email_template_category_rendered, expected_attributes_to_skip)
  end

  def validate_email_signature(email_signature, email_signature_rendered)
    expected_attributes = %w(uid name text html created_at)
    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_signature, email_signature_rendered, expected_attributes_to_skip)
  end

  def validate_skin(skin, skin_rendered)
    expected_attributes = %w(uid name)
    spec_validate_attributes(expected_attributes, skin, skin_rendered)
  end

  def validate_genie_rule(genie_rule, genie_rule_rendered)
    expected_attributes = %w(uid from_address to_address subject list_id)
    spec_validate_attributes(expected_attributes, genie_rule, genie_rule_rendered)
  end

  def verify_models_expected(models_expected, models_rendered, key)
    expect(models_rendered.length).to eq(models_expected.length)

    model_keys_rendered = []

    models_rendered.each do |model_rendered|
      model_keys_rendered << model_rendered[key]
    end

    models_expected.each do |model_expected|
      expect(model_keys_rendered.include?(model_expected.send(key))).to eq(true)
    end
  end

  def verify_models_unexpected(models_unexpected, models_rendered, key)
    model_keys_rendered = []

    models_rendered.each do |model_rendered|
      model_keys_rendered << model_rendered[key]
    end

    models_unexpected.each do |model_unexpected|
      expect(model_keys_rendered.include?(model_unexpected.send(key))).to eq(false)
    end
  end

  def verify_email(email, email_expected)
    email_expected.each do |k, v|
      next if k == "html_part"
      expect(email.send(k)).to eq(v)
    end

    verify_premailer_html(email["html_part"], email_expected["html_part"])
  end

  def verify_emails_in_gmail_label(gmail_account, label_id, emails_expected)
    label = gmail_account.gmail_labels.find_by_label_id(label_id)
    emails = label.emails.order(:date)
    expect(emails.count).to eq(emails_expected.length)

    emails.zip(emails_expected).each do |email, email_expected|
      verify_email(email, email_expected)
    end
  end

  def verify_premailer_html(rendered_html, expected_html)
    premailer_expected_html = premailer_html(expected_html)

    expect(rendered_html).to eq(premailer_expected_html)
  end

  def capybara_signin_user(user)
    visit mock_signin_path(user_id: user.id)
  end

  def gmail_o_auth2_url(force = false)
    o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)

    o_auth2_base_client.redirect_uri = "#{$config.url}/gmail_oauth2_callback"
    o_auth2_base_client.scope = GmailAccount::SCOPES

    options = {}
    options[:access_type] = :offline
    options[:approval_prompt] = force ? :force : :auto
    options[:include_granted_scopes] = true

    url = o_auth2_base_client.authorization_uri(options).to_s()
    return url
  end

  def capybara_link_gmail(gmail_email = SpecMisc::GMAIL_TEST_EMAIL,
                          gmail_passowrd = SpecMisc::GMAIL_TEST_PASSWORD)
    visit gmail_o_auth2_url(true)

    if !has_field?('Email')
      sleep(2)
      click_button('Accept')
      expect(page).to have_content(I18n.t('gmail.authenticated'))
    else
      fill_in('Email', :with => gmail_email)
      fill_in('Password', :with => gmail_passowrd)
      click_button('Sign in')

      sleep(2)
      click_button('Accept')
      expect(page).to have_content(I18n.t('gmail.authenticated'))
    end
  end
end
