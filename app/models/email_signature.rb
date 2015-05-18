# == Schema Information
#
# Table name: email_signatures
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :text
#  name       :text
#  text       :text
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

class EmailSignature < ActiveRecord::Base
  belongs_to :user

  validates :user, :uid, :name, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
