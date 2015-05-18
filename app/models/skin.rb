# == Schema Information
#
# Table name: skins
#
#  id         :integer          not null, primary key
#  uid        :text
#  name       :text
#  created_at :datetime
#  updated_at :datetime
#

class Skin < ActiveRecord::Base
  validates :name, presence: true
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
