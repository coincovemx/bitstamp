require 'spec_helper'

describe Bitstamp do
  before { Bitstamp.api_version = nil }

  describe :sanity_check! do
    context 'not properly configured' do
      it { -> { Bitstamp.sanity_check! }.should raise_error }
    end
    context 'properly configured' do
      let(:nonce_parameter_generator) do
        Proc.new do
          "#{Time.now.to_i}#{(Time.now.nsec / 1_000_000)}".to_i
        end
      end

      before {
        Bitstamp.setup do |config|
          config.key = 'test'
          config.secret = 'test'
          config.client_id = 'test'
          config.nonce_parameter_generator = nonce_parameter_generator
        end
      }
      it { -> { Bitstamp.sanity_check! }.should_not raise_error }

      it 'generates the nonce parameter using the provided block' do
        expect(Bitstamp.nonce_parameter).to eq nonce_parameter_generator.call
      end
    end
  end

  describe :orders do
    it { should respond_to :orders }
  end

  describe :ticket, vcr: {cassette_name: 'bitstamp/ticker'} do
    subject { Bitstamp.ticker }
    it { should be_kind_of Bitstamp::Ticker }
    its(:high) { should == "124.90" }
    its(:last) { should == "124.55" }
    its(:timestamp) { should == "1380237724" }
    its(:bid) { should == "124.55" }
    its(:volume) { should == "7766.46908740" }
    its(:low) { should == "123.00" }
    its(:ask) { should == "124.56" }

    describe 'for api version v2', vcr: {cassette_name: 'bitstamp/v2/ticker'} do
      before { Bitstamp.api_version = 'v2' }

      subject { Bitstamp.ticker }
      it { should be_kind_of Bitstamp::Ticker }
      its(:high)      { should == '4445.09' }
      its(:last)      { should == '4430.00' }
      its(:timestamp) { should == '1503678718' }
      its(:bid)       { should == '4427.00' }
      its(:vwap)      { should == '4311.16' }
      its(:volume)    { should == '9703.38924092' }
      its(:low)       { should == '4185.67' }
      its(:ask)       { should == '4430.00' }
      its(:open)      { should == '4308.80' }
    end
  end

  describe :balance, vcr: {cassette_name: 'bitstamp/balance'} do
    context "configured" do
      subject { Bitstamp.balance }
      before { setup_bitstamp }
      it { should == {"btc_reserved"=>"0", "fee"=>"0.4000", "btc_available"=>"0", "usd_reserved"=>"1.02", "btc_balance"=>"0", "usd_balance"=>"6953.07", "usd_available"=>"6952.05"} }
    end
    context "not configured" do
      it { expect { Bitstamp.balance }.to raise_exception(Bitstamp::MissingConfigExeception, "Bitstamp Gem not properly configured") }
    end
  end

  describe :order_book, vcr: {cassette_name: 'bitstamp/order_book'} do
    let(:order_book) { Bitstamp.order_book }
    subject { order_book }
    it { should be_kind_of Hash }
    it { should have_key("asks") }
    it { should have_key("bids") }
    it { order_book["asks"].should be_kind_of Array }
    it { order_book["bids"].should be_kind_of Array }
  end

  describe :withdraw_bitcoins do
    before {setup_bitstamp}
    context "Failed to supply correct arguments", vcr: {cassette_name: 'bitstamp/withdraw_bitcoins/wrong_arguments'} do
      subject { Bitstamp.withdraw_bitcoins(amount:100) }
      #its(:error) { should == "Required parameters not supplied, :amount, :address" }
    end
    context "Failed to withdraw bitcoins", vcr: {cassette_name: 'bitstamp/withdraw_bitcoins/failure'} do
      subject { Bitstamp.withdraw_bitcoins(:amount=>100, :address=>"17Vr8d1yWrA226QNYZLDwaG4vDMUEaT9t5") }
      it {should == {"error"=>{"amount"=>["You have only 0 BTC available. Check your account balance for details."]}}}
      #its(:error) { should == "Required parameters not supplied, :amount, :address" }
    end
    # context "succesfully withdrew bitcoins", vcr: {cassette_name: 'bitstamp/withdraw_bitcoins/success'} do
    #   subject { Bitstamp.withdraw_bitcoins(:amount=>0.04976353, :address=>"17Vr8d1yWrA226QNYZLDwaG4vDMUEaT9t5") }
    #   it {should =='true'}
    #   #its(:error) { should == "Required parameters not supplied, :amount, :address" }
    # end
  end
  describe :unconfirmed_user_deposits, vcr: {cassette_name: 'bitstamp/unconfirmed_user_deposits'}  do
    before {setup_bitstamp}
    subject { Bitstamp.unconfirmed_user_deposits }
    it {should be_kind_of Array}

  end
  #
  # Works but for privacy reasons I dont want to include the cassette
  #
  # describe :bitcoin_deposit_address, vcr: {cassette_name: 'bitstamp/bitcoin_deposit_address'} do
  #   before {setup_bitstamp}
  #   subject {Bitstamp.bitcoin_deposit_address}
  #   #it {should match /^[13][a-zA-Z0-9]{26,33}$/} TODO:fix this spec
  # end
end
