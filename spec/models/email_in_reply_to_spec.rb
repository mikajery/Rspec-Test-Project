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

require 'rails_helper'

describe EmailInReplyTo, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  # relationship
  it { should belong_to :email }

  # columns
  it { should have_db_column(:email_id).of_type(:integer)  }
  it { should have_db_column(:in_reply_to_message_id).of_type(:text)  }
  it { should have_db_column(:position).of_type(:integer)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }  

  # indexes
  it { should have_db_index([:email_id, :in_reply_to_message_id, :position]).unique(true) }
  it { should have_db_index(:email_id) }

  # validation
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:in_reply_to_message_id) }
end
