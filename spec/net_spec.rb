require 'spec_helper'

describe Bitstamp::Net do
  let(:nonce_parameter_generator) do
    Proc.new do
      "#{Time.now.to_i}#{(Time.now.nsec / 1_000_000)}".to_i
    end
  end

  before do
    Bitstamp.setup do |config|
      config.key = 'test'
      config.secret = 'test'
      config.client_id = 'test'
      config.nonce_parameter_generator = nonce_parameter_generator
    end
  end

  it 'generates the nonce parameter using the provided block' do
    expect(Bitstamp::Net.nonce_parameter).to eq nonce_parameter_generator.call
  end
end