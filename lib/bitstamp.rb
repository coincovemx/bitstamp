require 'active_support/dependencies'
require 'active_model'
require 'httpi'
require 'json'
require 'hmac-sha2'

require 'bitstamp/net'
require 'bitstamp/helper'
require 'bitstamp/collection'
require 'bitstamp/model'

require 'bitstamp/orders'
require 'bitstamp/transactions'
require 'bitstamp/ticker'

String.send(:include, ActiveSupport::Inflector)

module Bitstamp

  # Connection timeouts
  mattr_accessor :conn_timeout

  # API Key
  mattr_accessor :key

  # Bitstamp secret
  mattr_accessor :secret

  # Bitstamp client ID
  mattr_accessor :client_id

  # Bitstamp API Version
  mattr_accessor :api_version

  # Bitstamp nonce parameter generator
  mattr_accessor :nonce_parameter_generator

  # Currency
  mattr_accessor :currency
  @@currency = :usd

  def self.api_path
    !api_version.nil? && "api/#{api_version}"
  end

  def self.nonce_parameter
    return self.nonce_parameter_generator.call if nonce_parameter_generator
    (Time.now.to_f*10000).to_i.to_s
  end

  def self.orders
    self.sanity_check!
    Bitstamp::Orders.new(api_path)
  end

  def self.user_transactions
    self.sanity_check!
    Bitstamp::UserTransactions.new(api_path)
  end

  def self.transactions(currency_pair = nil)
    Bitstamp::Transactions.new(base_path: api_path).from_api(currency_pair)
  end

  def self.balance(currency_pair = nil)
    self.sanity_check!

    JSON.parse Bitstamp::Net.post([api_path, 'balance']).body
  end

  def self.withdraw_bitcoins(options = {})
    self.sanity_check!
    if options[:amount].nil? || options[:address].nil?
      raise MissingConfigExeception.new("Required parameters not supplied, :amount, :address")
    end
    response_body = Bitstamp::Net.post('/bitcoin_withdrawal',options).body
    if response_body != 'true'
      return JSON.parse response_body
    else
      return response_body
    end
  end

  def self.bitcoin_deposit_address
    # returns the deposit address
    self.sanity_check!
    return Bitstamp::Net.post('/bitcoin_deposit_address').body
  end

  def self.unconfirmed_user_deposits
    self.sanity_check!
    return JSON.parse Bitstamp::Net.post("/unconfirmed_btc").body
  end

  def self.ticker(currency_pair = nil)
    return Bitstamp::Ticker.new(base_path: api_path).from_api(currency_pair)
  end

  def self.order_book
    return JSON.parse Bitstamp::Net.get('/order_book/').body
  end

  def self.setup
    yield self
  end

  def self.configured?
    self.key && self.secret && self.client_id
  end

  def self.sanity_check!
    unless configured?
      raise MissingConfigExeception.new("Bitstamp Gem not properly configured")
    end
  end

  class MissingConfigExeception<Exception;end;
end
