require 'spec_helper'

describe Bitstamp::Orders do
  before { setup_bitstamp }
  before { Bitstamp.api_version = nil }

  describe :all, vcr: {cassette_name: 'bitstamp/orders/all'} do
    subject { Bitstamp.orders.all }
    it { should be_kind_of Array }
    describe "first order" do
      subject { Bitstamp.orders.all.first }
      its(:price) { should == "1.01" }
      its(:amount) { should == "1.00000000" }
      its(:type) { should == 0 }
      its(:datetime) { should == "2013-09-26 23:15:04" }
    end
  end

  describe :sell do
    context "no permission found", vcr: {cassette_name: 'bitstamp/orders/sell/failure'} do
      subject { Bitstamp.orders.sell(:amount => 1, :price => 1000) }
      it { should be_kind_of Bitstamp::Order }
      its(:error) { should == "No permission found" }
    end
  end

  describe 'market orders' do
    before do
      VCR.turn_off!
    end

    after do
      VCR.turn_on!
    end

    it 'is successfully executed' do
      stub_request(:post, "https://www.bitstamp.net/api/v2/buy/market/btcusd/")
        .to_return(status: 200, body:  fixture('successful_order_bitstamp.json'), headers: { 'Content-Type' => 'application/json' })
      executed_order = Bitstamp.orders.market_buy(:amount => 1, :price => 1000)
      expect(executed_order).to be_kind_of Bitstamp::Order
      expect(executed_order.price).to eq "1.25"
    end

    it 'throws an error' do
      stub_request(:post, "https://www.bitstamp.net/api/v2/buy/market/btcusd/")
        .to_return(status: 200, body:  fixture('market_order_error.json'), headers: { 'Content-Type' => 'application/json' })
      executed_order = Bitstamp.orders.market_buy(:amount => 1, :price => 1000)
      expect(executed_order.price).to be_nil
      expect(executed_order.reason).not_to be_nil
      expect(executed_order.status).to eq 'error'
    end
  end

  describe :buy, vcr: {cassette_name: 'bitstamp/orders/buy'} do
    subject { Bitstamp.orders.buy(:amount => 1, :price => 1.01) }
    it { should be_kind_of Bitstamp::Order }
    its(:price) { should == "1.01" }
    its(:amount) { should == "1" }
    its(:type) { should == 0 }
    its(:datetime) { should == "2013-09-26 23:26:56.849475" }
    its(:error) { should be_nil }

    describe 'buy in v2' do
      it 'is successfully created' do
        Bitstamp.api_version = 'v2'
        stub_request(:post, "https://www.bitstamp.net/api/v2/buy/btcusd/")
          .to_return(status: 200, body:  fixture('successful_order_bitstamp.json'), headers: { 'Content-Type' => 'application/json' })
        order = Bitstamp.orders.buy(amount: 1, price: 1000)
        expect(order).to be_kind_of Bitstamp::Order
        expect(order.price).to eq "1.25"
      end

      describe 'for other ETH' do
        it 'is successfully created' do
          Bitstamp.api_version = 'v2'
          stub_request(:post, "https://www.bitstamp.net/api/v2/buy/ethusd/")
            .to_return(status: 200, body:  fixture('successful_order_bitstamp.json'), headers: { 'Content-Type' => 'application/json' })
          order = Bitstamp.orders.buy(amount: 1, price: 1000, currency_pair: 'ethusd')
          expect(order).to be_kind_of Bitstamp::Order
          expect(order.price).to eq "1.25"
        end
      end
    end
  end
end
