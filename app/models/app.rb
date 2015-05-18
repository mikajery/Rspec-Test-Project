# == Schema Information
#
# Table name: apps
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  name         :text
#  description  :text
#  app_type     :text
#  callback_url :text
#  created_at   :datetime
#  updated_at   :datetime
#

class App < ActiveRecord::Base
  belongs_to :user
  
  has_many :installed_apps,
           :dependent => :destroy

  enum :app_type => { :panel => 'panel' }
  
  validates :user, :uid, :name, :description, :app_type, :callback_url, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
