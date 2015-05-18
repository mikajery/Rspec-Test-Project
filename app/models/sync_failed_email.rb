# == Schema Information
#
# Table name: sync_failed_emails
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  email_uid          :text
#  result             :text
#  exception          :text
#  created_at         :datetime
#  updated_at         :datetime
#

class SyncFailedEmail < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  validates :email_account, :email_uid, presence: true
  
  def SyncFailedEmail.create_retry(email_account, email_uid, result: nil, ex: nil)
    sync_failed_email = nil
    
    retry_block do
      sync_failed_email = SyncFailedEmail.find_or_create_by!(:email_account => email_account,
                                                             :email_uid => email_uid)
      sync_failed_email.result = result.to_yaml if result
      sync_failed_email.exception = ex.to_yaml if ex
      sync_failed_email.save!
    end
    
    return sync_failed_email
  end
end
