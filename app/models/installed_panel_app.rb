# == Schema Information
#
# Table name: installed_panel_apps
#
#  id         :integer          not null, primary key
#  panel      :text             default("right")
#  position   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class InstalledPanelApp < ActiveRecord::Base
  enum :panel => { :right => 'right' }
  
  has_one :installed_app,
          :as => :installed_app_subclass

  validates :installed_app, :panel, :position, presence: true
end
