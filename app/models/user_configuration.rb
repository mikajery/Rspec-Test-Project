# == Schema Information
#
# Table name: user_configurations
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  demo_mode_enabled          :boolean          default(TRUE)
#  keyboard_shortcuts_enabled :boolean          default(TRUE)
#  genie_enabled              :boolean          default(TRUE)
#  split_pane_mode            :text             default("horizontal")
#  developer_enabled          :boolean          default(FALSE)
#  skin_id                    :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  email_list_view_row_height :integer
#  auto_cleaner_enabled       :boolean          default(FALSE)
#  inbox_tabs_enabled         :boolean
#  email_signature_id         :integer
#

class UserConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :skin
  belongs_to :email_signature

  validates :user, presence: true

  enum :split_pane_mode => { :off => 'off', :horizontal => 'horizontal', :vertical => 'vertical' }
end
