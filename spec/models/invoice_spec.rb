require 'spec_helper'


describe Invoice, "requirements" do
  it 'should have constants' do
    expect(Invoice::NUMBER_SEED).to     be > 10000 # this keeps the invoice # not so obvious
    expect(Invoice::CHARACTERS_SEED).to be > 9
  end
end

describe Invoice, "instance methods" do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @invoice = FactoryGirl.create(:invoice, created_at: '2010-11-26 23:55:14')
  end

  context '.order_ship_address_lines' do
    it 'should display invoice created_at date in the correct format' do
      #@invoice.order.expects(:ship_address).returns(create(:address))
      @invoice.order.ship_address.expects(:try).with(:full_address_array).once
      @invoice.order_ship_address_lines
    end
  end

  context '.order_billing_address_lines' do
    it 'should display invoice created_at date in the correct format' do
      #@invoice.order.expects(:bill_address).returns(create(:address))
      @invoice.order.bill_address.expects(:try).with(:full_address_array).once
      @invoice.order_billing_address_lines
    end
  end



  #invoice_date(format = :us_date)
  context '.invoice_date' do
    it 'should display invoice created_at date in the correct format' do
      expect(@invoice.invoice_date).to eq '11/26/2010'
    end
  end

  context '.number' do
    it 'should exist and not = id' do
      expect(@invoice.number).not_to    eq @invoice.id
      expect(@invoice.number.length).to be > 3
    end
  end

  context ".capture_complete_order" do
    it 'should create a CreditCardCapture transaction' do
      @invoice.stubs(:amount).returns(20.50)
      #@invoice.stubs(:batches).returns([])
      expect(@invoice.capture_complete_order).to be true
      expect(@invoice.order.user.transaction_ledgers.size).to eq 2
    end

    context ".authorize_complete_order" do
      it 'should create a CreditCardReceivePayment transaction' do
        @invoice.stubs(:amount).returns(20.50)
        expect(@invoice.authorize_complete_order).to be true
        expect(@invoice.order.user.transaction_ledgers.size).to eq 2
        expect(@invoice.capture_complete_order).to be true
        expect(@invoice.order.user.transaction_ledgers.size).to eq 4
      end

      context 'cancel_authorized_payment' do
        it 'should create a CreditCardReceivePayment transaction then cancel' do
          @invoice.stubs(:amount).returns(20.50)
          @invoice.authorize_complete_order

          expect(@invoice.cancel_authorized_payment).to be true
          expect(@invoice.order.user.transaction_ledgers.size).to eq 4
          revenue_credits = []
          ar_credits      = []
          revenue_debits  = []
          ar_debits       = []
          @invoice.order.user.transaction_ledgers.each do |ledger|
            if ledger.transaction_account_id == TransactionAccount::REVENUE_ID
              revenue_credits << ledger.credit
              revenue_debits  << ledger.debit
            end
            if ledger.transaction_account_id == TransactionAccount::ACCOUNTS_RECEIVABLE_ID
              ar_credits << ledger.credit
              ar_debits  << ledger.debit
            end
          end
          ## credits and debits should cancel themselves out
          expect(revenue_credits.sum).not_to eq 0
          expect(ar_credits.sum).not_to eq 0
          expect(revenue_credits.sum).to  eq revenue_debits.sum
          expect(ar_credits.sum).to       eq ar_debits.sum
        end
      end
    end
  end
end

describe Invoice, "#process_rma(return_amount, order)" do
  it 'should create a invoice for an RMA' do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    order = FactoryGirl.create(:order)
    invoice = Invoice.process_rma(20.55, order)
    #@invoice.stubs(:batches).returns([])
    #expect(invoice.capture_complete_order).to be_true
    expect(invoice.order.user.transaction_ledgers.size).to eq 2
    expect(invoice.state).to eq 'refunded'
  end
end

describe Invoice, "Class methods" do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end

  describe Invoice, "#id_from_number(num)" do
    it 'should return invoice id' do
      invoice     = FactoryGirl.create(:invoice)
      invoice_id  = Invoice.id_from_number(invoice.number)
      expect(invoice_id).to eq invoice.id
    end
  end

  describe Invoice, "#find_by_number(num)" do
    it 'should find the invoice by number' do
      invoice = FactoryGirl.create(:invoice)
      find_invoice = Invoice.find_by_number(invoice.number)
      expect(find_invoice.id).to eq invoice.id
    end
  end
end

describe Invoice, "#generate(order_id, charge_amount)" do
  it 'should find the invoice by number' do
    order = FactoryGirl.create(:order)
    charge_amount = 20.15
    invoice = Invoice.generate(order.id, charge_amount)
    expect(invoice.id).to           be nil
    expect(invoice.invoice_type).to eq Invoice::PURCHASE
    expect(invoice.valid?).to       be true
  end
end
describe Invoice, 'optimize' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end
  describe Invoice, ".unique_order_number" do
    it 'should return a unique_order_number' do
      invoice = FactoryGirl.create(:invoice)
      expect(invoice.send(:unique_order_number).length).to be > 8
    end
  end

  describe Invoice, ".authorization_reference" do
    it 'will return a confirmation id if there is a successful payment' do
      invoice = FactoryGirl.create(:invoice)
      payment = FactoryGirl.create(:payment, :invoice => invoice, :action => 'authorization', :success => true, :confirmation_id => 'good')
      expect(invoice.authorization_reference).to eq payment.confirmation_id
    end
  end

  describe Invoice, ".succeeded?" do
    it 'will return a true if authorized or paid' do
      invoice = FactoryGirl.create(:invoice, :state => 'authorized')
      expect(invoice.succeeded?).to be true

      invoice = FactoryGirl.create(:invoice, :state => 'paid')
      expect(invoice.succeeded?).to be true
    end
  end
end

describe Invoice, ".integer_amount" do
  it 'should reprent the dollar amount in integer form' do
    invoice = FactoryGirl.create(:invoice, :amount => 13.56)
    expect(invoice.integer_amount).to eq 1356
  end
end

describe Invoice, ".authorize_payment(credit_card, options = {})" do
  skip "test for authorize_payment(credit_card, options = {})"
end

describe Invoice, ".capture_payment(options = {})" do
  skip "test for capture_payment(options = {})"
end

describe Invoice, ".user_id" do
  it 'should give the orders user_id' do
    invoice = FactoryGirl.create(:invoice)
    expect(invoice.user_id).to eq invoice.order.user_id
  end
end

describe Invoice, ".user" do
  it 'should give the orders user_id' do
    invoice = FactoryGirl.create(:invoice)
    expect(invoice.user.id).to eq invoice.order.user_id
  end
end
