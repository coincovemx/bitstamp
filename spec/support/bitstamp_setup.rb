RSpec.configure do |config|
  config.before(:each) do
    # The famous singleton problem
    Bitstamp.setup do |config|
      config.key = nil
      config.secret = nil
      config.client_id = nil
    end
  end
end

def setup_bitstamp
  Bitstamp.setup do |config|
    raise "You must set environment variable BITSTAMP_KEY and BITSTAMP_SECRET with your username and password to run specs." if ENV['BITSTAMP_KEY'].nil? or ENV['BITSTAMP_SECRET'].nil?
    config.key = ENV['BITSTAMP_KEY']
    config.secret = ENV['BITSTAMP_SECRET']
    config.client_id = ENV['BITSTAMP_CLIENT_ID']
    config.nonce_parameter_generator= lambda { "#{Time.now.to_i}#{(Time.now.nsec / 1_000_000)}".to_i }
  end
end
