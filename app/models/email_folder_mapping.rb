# == Schema Information
#
# Table name: email_folder_mappings
#
#  id                       :integer          not null, primary key
#  email_id                 :integer
#  email_folder_id          :integer
#  email_folder_type        :string(255)
#  email_thread_id          :integer
#  folder_email_date        :datetime
#  folder_email_draft_id    :text
#  folder_email_thread_date :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

class EmailFolderMapping < ActiveRecord::Base
  belongs_to :email
  belongs_to :email_thread
  belongs_to :email_folder, polymorphic: true

  validates :email_id, :email_thread_id, :email_folder_id, :email_folder_type, presence: true
  
  after_create {
    self.email_folder.update_counts()
  }

  after_destroy {
    self.email_folder.update_counts()
  }
end
