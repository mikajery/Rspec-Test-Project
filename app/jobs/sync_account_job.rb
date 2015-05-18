class SyncAccountJob < ActiveJob::Base
  queue_as :default

  def perform( gmail_account )
    gmail_account.sync_account

    gmail_account.update_attributes(sync_lock: false)
  end
end
