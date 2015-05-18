# == Schema Information
#
# Table name: email_rules
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  uid                     :text
#  from_address            :text
#  to_address              :text
#  subject                 :text
#  list_id                 :text
#  destination_folder_name :text
#  created_at              :datetime
#  updated_at              :datetime
#

class EmailRule < ActiveRecord::Base
  belongs_to :user

  validate :presence_of_rule_criteria
  validates :user, :uid, :destination_folder_name, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
  
  def presence_of_rule_criteria
    if from_address.blank? && to_address.blank? && subject.blank? && list_id.blank?
      errors[:base] << 'This email rule is invalid because no criteria was specified.'
    end
  end
end
