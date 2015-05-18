# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  email_address      :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Person < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  has_many :email_recipients,
           :dependent => :destroy

  validates :email_account, :email_address, presence: true

  before_validation {
    self.email_address = cleanse_email(self.email_address) if self.email_address
  }
end
