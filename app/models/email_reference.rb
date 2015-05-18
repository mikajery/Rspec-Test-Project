# == Schema Information
#
# Table name: email_references
#
#  id                    :integer          not null, primary key
#  email_id              :integer
#  references_message_id :text
#  position              :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class EmailReference < ActiveRecord::Base
  belongs_to :email

  validates :email, :references_message_id, :position, presence: true
end
