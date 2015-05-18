# == Schema Information
#
# Table name: email_trackers
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  email_uids         :text
#  email_subject      :text
#  email_date         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class EmailTracker < ActiveRecord::Base
  serialize :email_uids

  belongs_to :email_account, polymorphic: true
  
  has_many :email_tracker_recipients,
           :dependent => :destroy
  
  validates :email_account, :uid, :email_subject, :email_date, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
