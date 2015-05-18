# == Schema Information
#
# Table name: email_attachments
#
#  id                  :integer          not null, primary key
#  email_id            :integer
#  filename            :text
#  content_type        :text
#  file_size           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  uid                 :text
#  mime_type           :text
#  content_disposition :text
#  sha256_hex_digest   :text
#  gmail_attachment_id :text
#  s3_key              :text
#

class EmailAttachment < ActiveRecord::Base
  belongs_to :email

  validates :uid, :email, :file_size, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  before_destroy {
    log_exception() do
      self.delay.s3_delete(self.s3_key) if !self.s3_key.blank?
    end
  }

  after_commit {
    MimeTypeMapping.find_or_create_by(mime_type: content_type)
  }

  def self.order_and_filter(email_account, params)
    sort_dir = params[:dir] == "DESC" ? "DESC" : "ASC"

    if params[:order_by] == "name"
      order_by = "email_attachments.filename"
    elsif params[:order_by] == "size"
      order_by = "email_attachments.file_size"
    else
      order_by = "emails.date"
    end

    email_attachments = email_account.email_attachments.joins(:email).select(:uid, :filename).order("#{order_by} #{sort_dir}")

    unless params[:type].blank?
      mime_types = MimeTypeMapping.where(usable_category_cd: MimeTypeMapping.usable_categories[params[:type].to_sym])
      .pluck(:mime_type)
      email_attachments = email_attachments.where("content_type IN (?)", mime_types)
    end

    email_attachments
  end
end