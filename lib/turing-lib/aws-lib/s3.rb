require 'aws'

def s3_write_file(file_info, s3: nil, bucket: nil)
  s3 = AWS::S3.new if s3.nil?
  bucket = s3.buckets[$config.s3_bucket] if bucket.nil?

  object = bucket.objects[file_info[:s3_key]]
  options = {
      :content_length => file_info[:file].size,
      :acl => :public_read,
      :content_md5 => Digest::MD5.file(file_info[:file].path).base64digest,
      :content_disposition => file_info[:content_disposition],
      :content_type => file_info[:content_type]
  }
  object.write(file_info[:file], options)

  log_console("wrote #{file_info[:file].path} to s3 #{object.public_url.to_s}")
end

# No coverage because this function is not used.
# :nocov:
def s3_write_files(files_info)
  s3 = AWS::S3.new

  files_info.each do |file_info|
    s3_write_file(file_info, s3: s3)
  end
end
# :nocov:

def s3_url(s3_key)
  return "#{$config.s3_base_url}/#{s3_key}"
end

def s3_get_bucket
  s3 = AWS::S3.new
  bucket = s3.buckets[$config.s3_bucket]

  return bucket
end

def s3_delete(s3_key)
  bucket = s3_get_bucket()

  object = bucket.objects[s3_key]
  log_exception() { object.delete }
end

def s3_get_new_key()
  return random_string($config.s3_key_length)
end
