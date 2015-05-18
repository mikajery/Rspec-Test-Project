def parse_email_string(email_string)
  mail_address = Mail::Address.new(email_string)

  return :display_name => mail_address.display_name, :address => mail_address.address
rescue Exception
  m = email_string.match(/(.*)( ?<| <?)([^<@>]+@[^<@>]+)>?/)

  if m
    begin
      display_name = m[1].strip
      email_address = m[3].strip

      uri = URI(email_address)
      if uri.class != URI::Generic
        display_name = nil
        email_address = email_string
      end
    rescue
      display_name = nil
      email_address = email_string
    end
  else
    display_name = nil
    email_address = email_string
  end

  return { :display_name => display_name, :address => email_address }
end

def parse_email_list_id_header(list_id_header)
  return { :name => nil, :id => nil } if list_id_header.nil?

  if list_id_header.class != String
    list_id_value = list_id_header.decoded.force_utf8(true)
  else
    list_id_value = list_id_header
  end

  list_id_header_parsed = parse_email_string(list_id_value)
  list_name = list_id_header_parsed[:display_name]
  list_id = list_id_header_parsed[:address]

  if list_id.nil?
    m = list_id_value.match(/.*<(.+)>.*/)
    if m
      list_id = m[1]
    else
      list_id = list_id_value
      list_name = nil
    end
  end

  return { :name => list_name, :id => list_id }
end

def parse_email_list_subscription_header(list_subscription_header)
  return { :email => nil, :mailto => nil, :link => nil } if list_subscription_header.nil?

  if list_subscription_header.class != String
    list_subscription_value = list_subscription_header.decoded.force_utf8(true)
  else
    list_subscription_value = list_subscription_header
  end

  email = mailto = link = nil

  list_subscription_parts = list_subscription_value.split(',').map { |s| s.strip() }

  list_subscription_parts.each do |part|
    part_parsed = parse_email_string(part)

    uri = nil
    ignore_exception() do
      uri = URI(part_parsed[:address])
    end

    if part_parsed[:address][0] == '<' || (uri && uri.class != URI::Generic)
      # email parse failed

      next if part_parsed[:address] !~ /<(.+)>?/

      part_link = part_parsed[:address][/<(.+)>?/, 1]
      part_link = part_link[0 ... -1] if part_link[-1] == '>'

      begin
        uri = URI(part_link)

        if uri.class == URI::MailTo
          mailto = part_link if mailto.nil?
        elsif link.nil?
          link = part_link
        end
      rescue
      end
    else
      if email.nil?
        email = part_parsed
      elsif email[:display_name].blank? && !part_parsed[:display_name].blank?
        email = part_parsed
      end
    end
  end

  return { :email => email, :mailto => mailto, :link => link }
end

# sometimes list address in the list_id is missing the @
def get_email_list_address_from_list_id(list_id)
  m = list_id.match(/([^@]+)@(.+)/)

  if m
    name = m[1]
    domain = m[2]
  else
    m = list_id.match(/(.*)\.([^\.]+\.[^\.]+)/)

    if m
      name = m[1]
      domain = m[2]
    else
      name = list_id
      domain = nil
    end
  end

  return { :name => name, :domain => domain }
end

def parse_email_address_field(email_raw, field)
  email_addresses_parsed = []

  if email_raw[field] && email_raw[field].field.class != Mail::UnstructuredField
    email_raw[field].addrs.each do |addr|
      email_addresses_parsed << { :display_name => addr.display_name, :address => addr.address }
    end
  else
    email_field = email_raw.send(field)

    if email_field
      if email_field.class == String
        email_addresses_parsed << parse_email_string(email_field)
      else
        email_field.each do |email_string|
          email_addresses_parsed << parse_email_string(email_string)
        end
      end
    end
  end

  return email_addresses_parsed
end

def parse_email_headers(raw_headers)
  unfolded_headers = raw_headers.gsub(/#{Mail::Patterns::CRLF}#{Mail::Patterns::WSP}+/, ' ').
                                 gsub(/#{Mail::Patterns::WSP}+/, ' ')
  split_headers = unfolded_headers.split(Mail::Patterns::CRLF)

  headers = []
  split_headers.each { |header| headers << Mail::Field.new(header, nil, nil) }

  return headers
end

def cleanse_email(email)
  return nil if email.nil?
  return email.strip.downcase
end
