# == Schema Information
#
# Table name: email_tracker_views
#
#  id                         :integer          not null, primary key
#  email_tracker_recipient_id :integer
#  uid                        :text
#  ip_address                 :text
#  user_agent                 :text
#  created_at                 :datetime
#  updated_at                 :datetime
#

class EmailTrackerView < ActiveRecord::Base
  belongs_to :email_tracker_recipient

  validates :email_tracker_recipient, :uid, :ip_address, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
