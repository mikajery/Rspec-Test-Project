# == Schema Information
#
# Table name: email_in_reply_tos
#
#  id                     :integer          not null, primary key
#  email_id               :integer
#  in_reply_to_message_id :text
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class EmailInReplyTo < ActiveRecord::Base
  belongs_to :email

  validates :email, :in_reply_to_message_id, presence: true
end
