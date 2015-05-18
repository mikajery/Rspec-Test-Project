require 'rails_helper'

describe 'api/v1/email_reports/ip_stats_report', :type => :view do
  let(:ip_infos) { FactoryGirl.create_list(:ip_info, SpecMisc::MEDIUM_LIST_SIZE) }
  let(:email_ip_stats) do
    num_emails = 0

    ip_infos.map do |ip_info|
      num_emails += 1
      { :num_emails => num_emails, :ip_info =>ip_info }
    end
  end
  
  it 'returns the IP stats' do
    assign(:email_ip_stats, email_ip_stats)

    render

    json = JSON.parse(rendered)
    expect(json.keys).to eq(["ip_stats"])
    email_ip_stats_rendered = json

    email_ip_stats.zip(email_ip_stats_rendered["ip_stats"]).each do |email_ip_stat, email_ip_stat_rendered|
      expect(email_ip_stat_rendered['num_emails'].to_i).to eq(email_ip_stat[:num_emails].to_i)
      validate_ip_info(email_ip_stat[:ip_info], email_ip_stat_rendered['ip_info'])
    end
  end
end
