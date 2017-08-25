module Bitstamp
  class Orders < Bitstamp::Collection
    def all(options = {})
      path = [base_path, 'open_orders']
      Bitstamp::Helper.parse_objects! Bitstamp::Net.post(path).body, self.model
    end

    def create(options = {})
      path = self.order_path(options)
      Bitstamp::Helper.parse_object! Bitstamp::Net.post(path, options).body, self.model
    end

    def sell(options = {})
      options.merge!({
        type: Bitstamp::Order::SELL,
        side_execution: Bitstamp::Order::LIMIT_ORDER
      })

      self.create options
    end

    def buy(options = {})
      options.merge!({
        type: Bitstamp::Order::BUY,
        side_execution: Bitstamp::Order::LIMIT_ORDER
      })

      self.create options
    end

    def market_buy(options = {})
      options.merge!({
        type: Bitstamp::Order::BUY,
        side_execution: Bitstamp::Order::MARKET_ORDER
      })

      self.create options
    end

    def market_sell(options = {})
      options.merge!({
        type: Bitstamp::Order::SELL,
        side_execution: Bitstamp::Order::MARKET_ORDER
      })

      self.create options
    end

    def find(order_id)
      all = self.all
      index = all.index {|order| order.id.to_i == order_id}

      return all[index] if index
    end

    def status(order_id, options = {})
      options.merge!({id: order_id})
      Bitstamp::Helper.parse_objects! Bitstamp::Net.post("#{base_path}/order_status", options).body, self.model
    end

    def order_path(options = {})
      options[:currency_pair] = 'btcusd' if options[:currency_pair].to_s.empty? && Bitstamp.api_version == 'v2'
      type = (options[:type] == Bitstamp::Order::SELL ? 'sell' : 'buy')
      if options[:side_execution] == Bitstamp::Order::MARKET_ORDER
        market_order_path(type, options)
      else
        limit_order_path(type, options)
      end
    end

    def market_order_path(type, options = {})
      currency_pair = options[:currency_pair].to_s.empty? ? 'btcusd' : options[:currency_pair]
      "/v2/#{type}/market/#{currency_pair}"
    end

    def limit_order_path(type, options = {})
      [base_path, type, options[:currency_pair]]
    end
  end

  class Order < Bitstamp::Model
    MARKET_ORDER = :market
    LIMIT_ORDER = :limit_order
    BUY  = 0
    SELL = 1

    attr_accessor :type, :amount, :price, :id, :datetime, :status
    attr_accessor :error, :message, :reason

    def cancel!
      Bitstamp::Net.post("#{base_path}/cancel_order", {id: self.id}).body
    end
  end
end
