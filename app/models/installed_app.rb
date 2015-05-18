# == Schema Information
#
# Table name: installed_apps
#
#  id                          :integer          not null, primary key
#  installed_app_subclass_id   :integer
#  installed_app_subclass_type :string(255)
#  user_id                     :integer
#  app_id                      :integer
#  permissions_email_headers   :boolean          default(FALSE)
#  permissions_email_content   :boolean          default(FALSE)
#  created_at                  :datetime
#  updated_at                  :datetime
#

class InstalledApp < ActiveRecord::Base
  belongs_to :installed_app_subclass, polymorphic: true, :dependent => :destroy
  
  belongs_to :user
  belongs_to :app

  validates :user, :app, presence: true
end
