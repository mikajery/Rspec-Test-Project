require 'rails_helper'

describe 'Logging' do
  it '.log_message' do
    allow_any_instance_of(Exception).to receive(:message).and_return('message')
    allow_any_instance_of(Exception).to receive(:backtrace).and_return('backtrace')
    ex = Exception.new
    expect(ex.log_message).to eq("Exception: message\r\n\r\nbacktrace")
  end

  it '.log_exception' do
    block_to_call = -> { 1 }
    expect(log_exception(&block_to_call)).to eq(1)

    allow_any_instance_of(Object).to receive(:log_console_exception).with(StandardError)
    block_to_call_with_exception = -> { 1 / 0 }
    log_exception(&block_to_call_with_exception)
  end

  it '.log_email_exception' do
    ex = Exception.new
    allow_any_instance_of(Object).to receive(:log_email).and_return('logging')

    expect(log_email_exception(ex)).to eq('logging')
  end

  it '.log_console_exception' do
    ex = Exception.new
    allow_any_instance_of(Object).to receive(:log_console).and_return('logging')

    expect(log_console_exception(ex)).to eq('logging')
  end
end
