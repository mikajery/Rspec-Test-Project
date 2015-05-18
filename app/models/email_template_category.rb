class EmailTemplateCategory < ActiveRecord::Base
  belongs_to :user

  has_many :email_templates

  validates :user, :uid, :name, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
