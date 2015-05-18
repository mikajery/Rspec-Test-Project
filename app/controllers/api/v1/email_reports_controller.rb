class Api::V1::EmailReportsController < ApiController
  before_action do
    signed_in_user(true)
  end

  swagger_controller :email_reports, 'Email Reports Controller'

  # :nocov:
  swagger_api :ip_stats_report do
    summary 'Return email sender IP stats.'

    response :ok
  end
  # :nocov:

  def ip_stats_report
    email_ip_info_counts = current_user.emails.group(:ip_info_id).count
    ip_infos = IpInfo.where(:id => email_ip_info_counts.keys)

    @email_ip_stats = []

    ip_infos.each do |ip_info|
      num_emails = email_ip_info_counts[ip_info.id]

      @email_ip_stats.push({ :num_emails => num_emails,
                             :ip_info =>ip_info })
    end
  end

  # :nocov:
  swagger_api :volume_report do
    summary 'Return email volume report stats.'

    response :ok
  end
  # :nocov:

  def volume_report
    sent_label = current_user.gmail_accounts.first.sent_folder
    sent_emails_ids = sent_label ? sent_label.emails.pluck(:id) : [-1]
    sent_emails_ids = [-1] if sent_emails_ids.empty?

    volume_report_stats = {
        :received_emails_per_month =>
            current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(12).count,
        :received_emails_per_week =>
            current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(12).count,
        :received_emails_per_day =>
            current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count,

        :sent_emails_per_month =>
            current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(12).count,
        :sent_emails_per_week =>
            current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(12).count,
        :sent_emails_per_day =>
            current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count
    }

    volume_report_stats_short = {}
    volume_report_stats.each do |stat, data|
      volume_report_stats_short[stat] = {}
      data.each do |date, num_emails|
        if date
          volume_report_stats_short[stat][date.strftime($config.volume_report_date_format)] = num_emails
        else
          volume_report_stats_short[stat][date] = num_emails
        end
      end
    end

    render :json => volume_report_stats_short
  end

  # :nocov:
  swagger_api :contacts_report do
    summary 'Return contacts report stats.'

    response :ok
  end
  # :nocov:

  def contacts_report
    sent_label = current_user.gmail_accounts.first.sent_folder
    sent_emails_ids = sent_label ? sent_label.emails.pluck(:id) : [-1]
    sent_emails_ids = [-1] if sent_emails_ids.empty?

    contacts_report_stats = {
        :top_senders => current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
            group(:from_address).order('count_all DESC').limit(10).count,
        :bottom_senders => current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
            group(:from_address).order('count_all ASC').limit(10).count,
        :top_recipients => EmailRecipient.where(:email => sent_emails_ids).joins(:person).group(:email_address).
            order('count_all DESC').limit(10).count,
        :bottom_recipients => EmailRecipient.where(:email => sent_emails_ids).joins(:person).group(:email_address).
            order('count_all ASC').limit(10).count
    }

    render :json => contacts_report_stats
  end

  # :nocov:
  swagger_api :attachments_report do
    summary 'Return attachments report stats.'

    response :ok
  end
  # :nocov:

  def attachments_report
    content_type_counts = EmailAttachment.where(:email => current_user.emails).group(:content_type).
        order('count_all DESC').limit(10).count

    if content_type_counts.length > 0
      content_type_sizes = EmailAttachment.where(:email => current_user.emails,
                                                 :content_type => content_type_counts.keys).
          group(:content_type).average(:file_size)
    else
      content_type_sizes = {}
    end

    content_type_stats = {}
    content_type_counts.each do |content_type, num_attachments|
      content_type_stats[content_type] = {
          :num_attachments => num_attachments,
          :average_file_size => content_type_sizes[content_type].to_i
      }
    end

    attachments_report_stats = {
        :average_file_size => EmailAttachment.where(:email => current_user.emails).average(:file_size).to_i,
        :content_type_stats => content_type_stats
    }

    render :json => attachments_report_stats
  end

  # :nocov:
  swagger_api :lists_report do
    summary 'Return lists report stats.'

    response :ok
  end
  # :nocov:

  def lists_report
    list_report_stats = {}

    list_report_stats[:lists_email_daily_average] = Email.lists_email_daily_average(current_user)

    list_report_stats[:emails_per_list] =
        current_user.emails.where('list_id IS NOT NULL').group(:list_name, :list_id).order('emails_per_list DESC').
            pluck('list_name, list_id, COUNT(*) AS emails_per_list')

    list_report_stats[:email_threads_per_list] =
        current_user.emails.where('list_id IS NOT NULL').group(:list_name, :list_id).order('email_threads_per_list DESC').
            pluck('list_name, list_id, COUNT(DISTINCT email_thread_id) AS email_threads_per_list')

    list_report_stats[:email_threads_replied_to_per_list] =
        current_user.emails.where('list_id IS NOT NULL').having('COUNT(*) > 1').group(:list_name, :list_id, :email_thread_id).
            order('email_threads_replied_to_per_list DESC').
            pluck('list_name, list_id, COUNT(*) AS email_threads_replied_to_per_list')

    list_report_stats[:sent_emails_per_list] = []
    list_report_stats[:sent_emails_replied_to_per_list] = []

=begin
      sent_label = current_user.gmail_accounts.first.sent_folder
      if sent_label
        list_ids = current_user.emails.where('list_id IS NOT NULL').pluck('DISTINCT list_id')
        list_ids_parsed = list_ids.map { |list_id| parse_email_string(list_id) }

        list_email_addresses = list_ids_parsed.map do |list_id_parsed|
          list_address_parsed = get_email_list_address_from_list_id(list_id_parsed[:address].downcase)
          "#{list_address_parsed[:name]}@#{list_address_parsed[:domain]}"
        end

        email_ids_to_lists = EmailRecipient.joins(:person).where('"people"."email_address" IN (?)', list_email_addresses).pluck(:email_id)
        list_report_stats[:sent_emails_per_list] = sent_label.emails.where(:id => email_ids_to_lists).
                                                              where('list_id IS NOT NULL').
                                                              group(:list_id).order('sent_emails_per_list DESC').
                                                              pluck('list_id, COUNT(*) AS sent_emails_per_list')
=begin
        list_report_stats[:sent_emails_per_list] =
            sent_label.emails.where('list_id IS NOT NULL').group(:list_id).
                       order('sent_emails_per_list DESC').
                       pluck('list_id, COUNT(*) AS sent_emails_per_list')
=end
=begin
        sent_list_email_message_ids = sent_label.emails.where('list_id IS NOT NULL').pluck(:message_id)

        if sent_list_email_message_ids.length > 0
          list_report_stats[:sent_emails_replied_to_per_list] =
              current_user.emails.joins(:email_in_reply_tos).
                           where('"email_in_reply_tos"."in_reply_to_message_id" IN (?)', sent_list_email_message_ids).
                           group(:list_id).order('sent_emails_replied_to_per_list DESC').
                           pluck('list_id, COUNT(DISTINCT "email_in_reply_tos"."in_reply_to_message_id") AS sent_emails_replied_to_per_list')
        else
          list_report_stats[:sent_emails_replied_to_per_list] = []
        end
      else
        list_report_stats[:sent_emails_per_list] = []
        list_report_stats[:sent_emails_replied_to_per_list] = []
      end
=end

    render :json => list_report_stats
  end

  # :nocov:
  swagger_api :threads_report do
    summary 'Return threads report stats.'

    response :ok
  end
  # :nocov:

  def threads_report
    @average_thread_length =
        current_user.gmail_accounts.first.email_threads.count > 0 ?
            current_user.emails.count / current_user.gmail_accounts.first.email_threads.count : 0

    @top_email_threads = EmailThread.where(:id => current_user.emails.group(:email_thread_id).
        order('count_all DESC').limit(10).count.keys).includes(:latest_email).order('emails_count DESC')
  end

  # :nocov:
  swagger_api :folders_report do
    summary 'Return folders report stats.'

    response :ok
  end
  # :nocov:

  def folders_report
    folders_report_stats = {}

    num_emails = current_user.emails.count
    inbox_label = current_user.gmail_accounts.first.inbox_folder
    sent_label = current_user.gmail_accounts.first.sent_folder
    draft_label = current_user.gmail_accounts.first.drafts_folder
    trash_label = current_user.gmail_accounts.first.trash_folder
    spam_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SPAM')
    starred_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('STARRED')

    folders_report_stats[:percent_inbox] = inbox_label && num_emails > 0 ? inbox_label.emails.count / num_emails.to_f : 0
    folders_report_stats[:percent_unread] = current_user.emails.where(:seen => false).count
    folders_report_stats[:percent_sent] = sent_label && num_emails > 0 ? sent_label.emails.count / num_emails.to_f : 0
    folders_report_stats[:percent_draft] = draft_label && num_emails > 0 ? draft_label.emails.count / num_emails.to_f : 0
    folders_report_stats[:percent_trash] = trash_label && num_emails > 0 ? trash_label.emails.count / num_emails.to_f : 0
    folders_report_stats[:percent_spam] = spam_label && num_emails > 0 ? spam_label.emails.count / num_emails.to_f : 0
    folders_report_stats[:percent_starred] = starred_label && num_emails > 0 ? starred_label.emails.count / num_emails.to_f : 0

    render :json => folders_report_stats
  end

  # :nocov:
  swagger_api :impact_report do
    summary 'Return impact report stats.'

    response :ok
  end
  # :nocov:

  def impact_report
    impact_report_stats = {}

    sent_label = current_user.gmail_accounts.first.sent_folder

    if sent_label
      sent_email_message_ids = sent_label.emails.pluck(:message_id)

      sent_emails_replied_to = current_user.emails.joins(:email_in_reply_tos).
          where('"email_in_reply_tos"."in_reply_to_message_id" IN (?)',
                sent_email_message_ids).
          pluck('COUNT(DISTINCT "email_in_reply_tos"."in_reply_to_message_id")')[0]

      impact_report_stats[:percent_sent_emails_replied_to] =
          sent_label && sent_label.emails.count > 0 ? sent_emails_replied_to / sent_label.emails.count.to_f : 0
    else
      impact_report_stats[:percent_sent_emails_replied_to] = 0
    end

    render :json => impact_report_stats
  end
end
