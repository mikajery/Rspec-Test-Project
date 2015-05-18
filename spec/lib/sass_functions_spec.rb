require 'rails_helper'

describe Sass::Script::Functions do
  let(:foo_class) { Class.new { include Sass::Script::Functions } }
  let(:foo_object) { foo_class.new }

  it '#base64encode' do
    allow(foo_object).to receive(:assert_type) { true }
    test_string = double(value: 'Test String123')
    encoded_string = Sass::Script::Value::String.new(Base64.encode64(test_string.value))

    expect(foo_object.base64encode(test_string)).to eq encoded_string
  end
end

