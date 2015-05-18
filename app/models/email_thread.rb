# == Schema Information
#
# Table name: email_threads
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  created_at         :datetime
#  updated_at         :datetime
#  emails_count       :integer
#

class EmailThread < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :emails,
           -> { order date: :desc },
           dependent: :destroy

  # To include only first email. Can't use it right now as we need to include all mails to provide backward support for
  # count queries. Once we update all columns then we can use this method to reduce some load on in_folder method.
  has_one :latest_email, class_name: "Email"

  validates :email_account, :uid, presence: true

  def EmailThread.get_threads_from_ids(ids)
    email_threads = EmailThread.includes(:emails).where(:id => ids)
    return email_threads
  end

  def user
    return self.email_account.user
  end
end