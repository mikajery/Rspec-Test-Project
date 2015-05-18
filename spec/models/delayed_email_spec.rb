# == Schema Information
#
# Table name: delayed_emails
#
#  id                    :integer          not null, primary key
#  email_account_id      :integer
#  email_account_type    :string(255)
#  delayed_job_id        :integer
#  uid                   :text
#  tos                   :text
#  ccs                   :text
#  bccs                  :text
#  subject               :text
#  html_part             :text
#  text_part             :text
#  email_in_reply_to_uid :text
#  tracking_enabled      :boolean
#  bounce_back           :boolean          default(FALSE)
#  bounce_back_time      :datetime
#  bounce_back_type      :text
#  created_at            :datetime
#  updated_at            :datetime
#  attachment_s3_keys    :text
#

require 'rails_helper'

RSpec.describe DelayedEmail, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }

  # relationship
  it { should belong_to :email_account }

  # serialize
  it { should serialize(:tos) }
  it { should serialize(:ccs) }
  it { should serialize(:bccs) }
  it { should serialize(:attachment_s3_keys) }

  # columns
  it { should have_db_column(:email_account_id).of_type(:integer)  }
  it { should have_db_column(:email_account_type).of_type(:string)  }
  it { should have_db_column(:delayed_job_id).of_type(:integer)  }
  it { should have_db_column(:uid).of_type(:text)  }
  it { should have_db_column(:tos).of_type(:text)  }
  it { should have_db_column(:ccs).of_type(:text)  }
  it { should have_db_column(:bccs).of_type(:text)  }
  it { should have_db_column(:subject).of_type(:text)  }
  it { should have_db_column(:html_part).of_type(:text)  }
  it { should have_db_column(:text_part).of_type(:text)  }
  it { should have_db_column(:email_in_reply_to_uid).of_type(:text)  }
  it { should have_db_column(:tracking_enabled).of_type(:boolean)  }
  it { should have_db_column(:bounce_back).of_type(:boolean)  }
  it { should have_db_column(:bounce_back_time).of_type(:datetime)  }
  it { should have_db_column(:bounce_back_type).of_type(:text)  }
  it { should have_db_column(:created_at).of_type(:datetime)  }
  it { should have_db_column(:updated_at).of_type(:datetime)  }
  it { should have_db_column(:attachment_s3_keys).of_type(:text)  }

  # indexes
  it { should have_db_index(:delayed_job_id) }
  it { should have_db_index(:uid).unique(true) }

  # validation
  it { should validate_presence_of(:email_account) }
  it "populates the uid before validation" do
    delayed_email = FactoryGirl.build(:delayed_email, email_account: email_account, uid: nil)
     
    expect(delayed_email.save).to be(true)
  end

  # callback
  it "calls update_counts method of the email_folder before destroy" do
    delayed_job_id = delayed_job.id
    delayed_email = FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job_id)
    delayed_email.destroy
    expect(Delayed::Job.find_by(:id => delayed_job_id)).to be(nil)
  end

  # methods
  describe ".delayed_job" do

    let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job.id) }

    it 'returns the delayed job' do
      expected = Delayed::Job.find_by(:id => delayed_job.id)
      expect(delayed_email.delayed_job).to eq(expected)
    end
  end #__End of describe ".delayed_job"__

  describe ".send_and_destroy" do

    let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job.id) }

    it 'sends email to the email account' do
      delayed_email.email_account.should_receive(:send_email)  
      delayed_email.send_and_destroy
    end

    it 'is destroied' do
      delayed_email.email_account.stub(:send_email) { true }
      delayed_email.should_receive(:destroy!)  
      delayed_email.send_and_destroy
    end    
  end #__End of describe ".send_and_destroy"__

  describe ".send_at" do

    context 'when the delayed_job is nil' do
      let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: nil) }      

      it "returns nil" do
        expect(delayed_email.send_at).to be(nil)
      end
    end

    context 'when the delayed_job is not nil' do
      let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, delayed_job_id: delayed_job.id) }      

      it "returns the run_at of the delayed_job" do
        expect(delayed_email.send_at).to eq(delayed_email.delayed_job.run_at)
      end
    end
  end #__End of describe ".send_at"__
end
