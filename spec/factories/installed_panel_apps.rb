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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :installed_panel_app do
  	# association :installed_app, :factory => :installed_app
  	panel :right
  	position 1
  end
end
