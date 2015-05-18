# == Schema Information
#
# Table name: email_tracker_recipients
#
#  id               :integer          not null, primary key
#  email_tracker_id :integer
#  email_id         :integer
#  uid              :text
#  email_address    :text
#  created_at       :datetime
#  updated_at       :datetime
#

class EmailTrackerRecipient < ActiveRecord::Base
  belongs_to :email_tracker
  belongs_to :email

  has_many :email_tracker_views,
           :dependent => :destroy

  # TODO require :email after fix the SMTP send sync issue
  validates :email_tracker, :uid, :email_address, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
