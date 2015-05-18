collection @email_ip_stats => :ip_stats

node(:num_emails) { |email_ip_stat| email_ip_stat[:num_emails] }

node(:ip_info) do |email_ip_stat|
  partial('api/v1/ip_infos/show', :object => email_ip_stat[:ip_info])
end
