namespace :backward_support do
  desc "Update various counter cache columns"

  task :update_counter_cache_for_email_threads => :environment do
    EmailThread.find_each do |email_thread|
      EmailThread.reset_counters(email_thread, :emails)
    end
  end

  task :update_last_sync_at => :environment do
    GmailAccount.find_each do |gmail_account|
      gmail_account.update_attribute :last_sync_at, gmail_account.emails.maximum(:updated_at)
    end
  end

  task :populate_mime_type_mappings => :environment do
    EmailAttachment.find_each do |email_attachment|
      MimeTypeMapping.find_or_create_by(mime_type: email_attachment.content_type)
    end
    MimeTypeMapping.find_each do |mime_type_mapping|
      mime_type_mapping.update_attribute(:usable_category, :image) if (mime_type_mapping.mime_type.split("/").first rescue "") == "image"

      document_mime_types = ["application/pdf", "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "application/msword", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
      mime_type_mapping.update_attribute(:usable_category, :document) if document_mime_types.include?(mime_type_mapping.mime_type)
    end
  end
end