# == Schema Information
#
# Table name: email_recipients
#
#  id             :integer          not null, primary key
#  email_id       :integer
#  person_id      :integer
#  recipient_type :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class EmailRecipient < ActiveRecord::Base
  belongs_to :email
  belongs_to :person

  enum :recipient_type => { :to => 0, :cc => 1, :bcc => 2 }

  validates :email_id, :person, :recipient_type, presence: true
end
