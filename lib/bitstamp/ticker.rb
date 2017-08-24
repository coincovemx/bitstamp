module Bitstamp
  class Ticker < Bitstamp::Model
    attr_accessor :last, :high, :low, :volume, :bid, :ask, :timestamp, :vwap, :open

    def self.from_api(currency_pair = nil)
      new.from_api(currency_pair = nil)
    end

    def from_api(currency_pair = nil)
      path = [base_path, 'ticker', currency_pair]
      Bitstamp::Helper.parse_object!(Bitstamp::Net.get(path).body, self.class)
    end

    def self.method_missing method, *args
      ticker = from_api
      return ticker.send(method) if ticker.respond_to? method

      super
    end
  end
end
