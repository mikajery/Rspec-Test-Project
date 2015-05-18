# == Schema Information
#
# Table name: ip_infos
#
#  id           :integer          not null, primary key
#  ip           :inet
#  country_code :text
#  country_name :text
#  region_code  :text
#  region_name  :text
#  city         :text
#  zipcode      :text
#  latitude     :text
#  longitude    :text
#  metro_code   :text
#  area_code    :text
#  created_at   :datetime
#  updated_at   :datetime
#

class IpInfo < ActiveRecord::Base
  has_many :emails

  validates :ip, presence: true

  def IpInfo.find_latest_or_create_by_ip(ip)
    ip_info = IpInfo.where(ip: ip).order("created_at DESC").first
    if ip_info.nil? or ip_info.updated_at < 3.months.ago
      ip_info = IpInfo.create(ip: ip)
    end
    ip_info
  end
end