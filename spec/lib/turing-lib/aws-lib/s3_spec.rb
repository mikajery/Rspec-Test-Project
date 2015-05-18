require 'rails_helper'

describe 'AWS S3' do
  it '.s3_write_file' do
    bucket = double('bucket')
    object_with_public_url = double(public_url: 'public_url', write: nil)
    allow(bucket).to receive_message_chain(:objects, :[] => object_with_public_url)
    file = double(path: 'path', size: 10)
    file_info = { file: file,
                  s3_key: 'key',
                  content_disposition: 'content_disposition',
                  content_type: 'content_type'
                }
    buckets = double(:[] => bucket)
    allow_any_instance_of(AWS::S3).to receive(:buckets).and_return(buckets)
    allow_any_instance_of(Object).to receive(:log_console)
    digest = double(base64digest: 'digest')
    allow(Digest::MD5).to receive(:file).and_return(digest)

    s3_write_file(file_info)
  end

  it '.s3_url' do
    expect(s3_url('s3key')).to eq("#{$config.s3_base_url}/s3key")
  end

  it '.s3_get_bucket' do
    bucket = double('bucket')
    buckets = double(:[] => bucket)
    allow_any_instance_of(AWS::S3).to receive(:buckets).and_return(buckets)

    expect(s3_get_bucket).to eq bucket
  end

  it '.s3_delete' do
    bucket = double(:delete)
    buckets = double()
    allow(buckets).to receive_message_chain(:objects, :[] => bucket)
    allow_any_instance_of(Object).to receive(:s3_get_bucket).and_return(buckets)
    allow_any_instance_of(Object).to receive(:log_exception)

    s3_delete('key')
  end

  it '.s3_get_new_key' do
    expect(s3_get_new_key).to be_a String
    expect(s3_get_new_key.length).to eq $config.s3_key_length
  end
end
