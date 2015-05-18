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

require 'rails_helper'

describe UserConfiguration, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  before { user.user_configuration.destroy }

  # relationship
  it { should belong_to :user }
  it { should belong_to :skin }

  # columns
  it { should have_db_column(:user_id).of_type(:integer)  }
  it { should have_db_column(:demo_mode_enabled).of_type(:boolean)  }
  it { should have_db_column(:keyboard_shortcuts_enabled).of_type(:boolean)  }
  it { should have_db_column(:genie_enabled).of_type(:boolean)  }
  it { should have_db_column(:split_pane_mode).of_type(:text)  }
  it { should have_db_column(:developer_enabled).of_type(:boolean)  }
  it { should have_db_column(:skin_id).of_type(:integer)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }
  it { should have_db_column(:email_list_view_row_height).of_type(:integer)  }
  it { should have_db_column(:auto_cleaner_enabled).of_type(:boolean)  }
  it { should have_db_column(:inbox_tabs_enabled).of_type(:boolean)  }

  # indexes
  it { should have_db_index(:user_id).unique(true) }

  # enum
  it do
    should define_enum_for(:split_pane_mode).
      with({:off => 'off', :horizontal => 'horizontal', :vertical => 'vertical'})
  end

  # validation
  it { should validate_presence_of(:user) }
end
