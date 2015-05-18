class AddUploadJobToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :upload_attachments_delayed_job_id, :integer
    add_column :emails, :attachments_uploaded, :boolean, :default => false
  end
end
