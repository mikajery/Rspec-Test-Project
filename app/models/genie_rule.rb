# == Schema Information
#
# Table name: genie_rules
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  from_address :text
#  to_address   :text
#  subject      :text
#  list_id      :text
#  created_at   :datetime
#  updated_at   :datetime
#

class GenieRule < ActiveRecord::Base
  belongs_to :user

  validate :presence_of_rule_criteria
  validates :user, :uid, presence: true
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  def presence_of_rule_criteria
    if from_address.blank? && to_address.blank? && subject.blank? && list_id.blank?
      errors[:base] << 'This genie rule is invalid because no criteria was specified.'
    end
  end
end
