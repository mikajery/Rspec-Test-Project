object @ip_info

node(:ip) { |ip_info| ip_info[:ip].to_s }
attributes :country_code, :country_name
attributes :region_code, :region_name
attributes :city, :zipcode
attributes :latitude, :longitude
attributes :metro_code, :area_code
