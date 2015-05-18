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

# TODO write tests
class DelayedEmail < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  belongs_to :delayed_job

  serialize :tos
  serialize :ccs
  serialize :bccs
  serialize :attachment_s3_keys

  validates :email_account, presence: true
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
  
  before_destroy {
    delayed_job = self.delayed_job
    delayed_job.destroy!()
  }
  
  def delayed_job()
    return Delayed::Job.find_by(:id => self.delayed_job_id)
  end

  def send_and_destroy()
    self.email_account.send_email(self.tos, self.ccs, self.bccs,
                                  self.subject,
                                  self.html_part, self.text_part,
                                  self.email_in_reply_to_uid,
                                  self.bounce_back, self.bounce_back_time, self.bounce_back_type,
                                  self.attachment_s3_keys)
    self.destroy!()
  end
  
  def send_at()
    delayed_job = self.delayed_job
    return delayed_job ? delayed_job.run_at : nil
  end
end
