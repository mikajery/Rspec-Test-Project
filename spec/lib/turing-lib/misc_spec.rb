require 'rails_helper'

describe 'Misc' do
  it '.force_utf8' do
    expect('test'.force_utf8).to eq('test')
    expect('test'.encode('ascii').force_utf8).to eq('test')
    expect('test'.force_utf8(true)).to eq('test')
  end

  it '.to_s_local' do
    time_zone = 'Mon, 13 Apr 2015 12:58:20 UTC +00:00'
    expect(Time.zone.parse(time_zone).to_s_local).to eq('Apr 13 at  5:58 AM')
  end

  it '.open_force_file' do
    f = StringIO.new('test')
    allow_any_instance_of(Object).to receive(:open).and_return(f)

    expect(open_force_file(f)).to be_an_instance_of Tempfile
  end

  it '.random_string' do
    expect(random_string(10)).to be_an_instance_of String
    expect(random_string(10).length).to eq(10)
  end

  it '.retry_block' do
    call_block = -> { 1 }
    call_block_with_exception = -> { 1 / 0 }
    expect(retry_block &call_block).to eq 1
    expect{ retry_block &call_block_with_exception }.to raise_error
  end

  it '.append_where_condition' do
    expect(append_where_condition(['text', 'value'], 'camparison', 'value 2')).to eq 'valuevalue 2'
  end

  it '.premailer_html' do
    expect(premailer_html('<strong>test</strong')).to eq "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html><body><strong>test</strong></body></html>\n"
  end

  it '.destroy_batch' do
    150.times do
      FactoryGirl.create :user
    end

    destroy_all_batch(User.all)
    expect(User.count).to eq 0
  end

  it '.benchmark_time' do
    allow_any_instance_of(Object).to receive(:log_console).and_return('console')
    call_block = -> { 1 }

    expect(benchmark_time('benchmark', &call_block)).to eq 'console'
  end

  it '.most_common_value' do
    expect(most_common_value([1, 2 ,2 , 2, 3])).to eq 2
    expect(most_common_value([])).to eq nil
  end

  it '.ignore_exception' do
    call_block_with_exception = -> { 1 / 0 }
    expect{ ignore_exception &call_block_with_exception }.to_not raise_error
  end
end
