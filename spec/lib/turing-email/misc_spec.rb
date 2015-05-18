require 'rails_helper'

describe 'MiscEmail' do
  it '.clear_email_tables' do
    [Email, ImapFolder, GmailLabel, EmailFolderMapping, EmailThread,
     EmailReference, EmailInReplyTo, IpInfo, Person, EmailRecipient, EmailAttachment,
     SyncFailedEmail, EmailTracker, EmailTrackerRecipient, EmailTrackerView, ListSubscription].each do |model|
      FactoryGirl.create(model.model_name.to_s.underscore.to_sym)
     end

     clear_email_tables()
     [Email, ImapFolder, GmailLabel, EmailFolderMapping, EmailThread,
     EmailReference, EmailInReplyTo, IpInfo, Person, EmailRecipient, EmailAttachment,
     SyncFailedEmail, EmailTracker, EmailTrackerRecipient, EmailTrackerView, ListSubscription,
     Delayed::Job].each do |model|
      expect(model.count).to eq(0)
     end
  end

  it '.benchmark_email_creation' do
    FactoryGirl.create(:email)
    allow_any_instance_of(Object).to receive(:sleep)
    allow_any_instance_of(Object).to receive(:log_console)

    benchmark_email_creation()
  end
end
