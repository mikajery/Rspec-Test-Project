def clear_email_tables
  [Email, ImapFolder, GmailLabel, EmailFolderMapping, EmailThread,
   EmailReference, EmailInReplyTo, IpInfo, Person, EmailRecipient, EmailAttachment,
   SyncFailedEmail, EmailTracker, EmailTrackerRecipient, EmailTrackerView, ListSubscription,
   Delayed::Job].each do |m|
    m.delete_all
  end
end

def benchmark_email_creation
  counts = []

  while counts.length < 15
    counts.push(Email.count - counts.sum())
    sleep(1)
  end

  log_console(counts)

  counts = counts[1..-1]
  log_console(counts.sum / counts.length)
end
