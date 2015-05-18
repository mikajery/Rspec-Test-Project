require 'rails_helper'

context 'force_utf8' do
  it 'should convert strings to UTF-8' do
    expect('test'.encode('ascii').force_utf8.encoding.name).to eq('UTF-8')
  end
end

context 'encoded_with_bcc' do
  it 'should include the BCC header' do
    m = Mail.new
    m.bcc = 'foo@bar.com'
    email_rfc2822 = m.encoded_with_bcc
    expect(email_rfc2822.split("\r\n")[0]).to eq('Bcc: foo@bar.com')
  end
end

context 'retry_block' do
  it 'should retry the block' do
    attempts = 0
    retry_block(max_attempts: 4) do
      attempts += 1
      raise attempt.to_s if attempts < 4
    end
    
    expect(attempts).to eq(4)
  end
  
  it 'should ignore the specified exception' do
    attempts = 0
    
    begin
      retry_block(exceptions_to_ignore: [RuntimeError]) do
        attempts += 1
        raise RuntimeError
      end
    rescue RuntimeError
    end
    
    expect(attempts).to eq(1)
  end

  it 'should catch only the specified exception' do
    attempts = 0
    retry_block(max_attempts: 2, exceptions_to_catch: [StandardError]) do
      attempts += 1
      raise StandardError if attempts < 2
    end
    expect(attempts).to eq(2)

    attempts = 0
    begin
      retry_block(max_attempts: 2, exceptions_to_catch: [StandardError]) do
        attempts += 1
        raise RuntimeError if attempts < 2
      end
    rescue RuntimeError
    end
    expect(attempts).to eq(1)
  end
end

context 'append_where_condition' do
  it 'should create the where_conditions' do
    where_conditions = ['', []]
    
    append_where_condition(where_conditions, 'test<?', 1)
    
    expect(where_conditions[0]).to eq('test<?')
    expect(where_conditions[1]).to eq([1])
  
    append_where_condition(where_conditions, 'test2<?', 2)
    expect(where_conditions[0]).to eq('test<? AND test2<?')
    expect(where_conditions[1]).to eq([1, 2])
  end
end
