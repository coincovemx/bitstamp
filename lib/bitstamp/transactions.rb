module Bitstamp
  class UserTransactions < Bitstamp::Collection
    def all(options = {})
      path = [base_path, 'user_transactions', options[:currency_pair]]
      Bitstamp::Helper.parse_objects! Bitstamp::Net.post(path, options).body, self.model
    end

    def find(trans_id)
      all = self.all
      index = all.index {|trans| trans.id.to_i == trans_id}

      return all[index] if index
    end

    def create(options = {})
    end

    def update(options = {})
    end
  end

  class UserTransaction < Bitstamp::Model
    attr_accessor :datetime, :id, :type, :usd, :btc, :fee, :order_id, :btc_usd, :nonce
  end

  # adding in methods to pull the last public trades list
  class Transactions < Bitstamp::Model
    attr_accessor :date, :price, :tid, :amount

    def self.from_api(currency_pair = nil)
      new.from_api(currency_pair)
    end

    def from_api(currency_pair = nil)
      path = [base_path, 'transactions', currency_pair]
      Bitstamp::Helper.parse_objects! Bitstamp::Net.get(path).body, self.class
    end
  end
end
