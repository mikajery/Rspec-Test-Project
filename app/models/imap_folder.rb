# == Schema Information
#
# Table name: imap_folders
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  created_at         :datetime
#  updated_at         :datetime
#

class ImapFolder < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings

  validates :email_account_id, :email_account_type, :name, presence: true
end
