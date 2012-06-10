require 'spec_helper'


describe Invoice, "requirements" do
  it 'should have constants' do
    Invoice::NUMBER_SEED.should > 10000 # this keeps the invoice # not so obvious
    Invoice::CHARACTERS_SEED.should > 9
  end
end

describe Invoice, "instance methods" do
  before(:each) do 
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @invoice = create(:invoice, :created_at => '2010-11-26 23:55:14')
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
      @invoice.invoice_date.should == '11/26/2010'
    end
  end
  
  context '.number' do
    it 'should exist and not = id' do
      @invoice.number.should_not == @invoice.id
      @invoice.number.length.should > 3
    end
  end
  
  context ".capture_complete_order" do
    it 'should create a CreditCardCapture transaction' do
      @invoice.stubs(:amount).returns(20.50)
      #@invoice.stubs(:batches).returns([])
      @invoice.capture_complete_order.should be_true
      @invoice.order.user.transaction_ledgers.size.should == 2
    end
    
    context ".authorize_complete_order" do
      it 'should create a CreditCardReceivePayment transaction' do
        @invoice.stubs(:amount).returns(20.50)      
        @invoice.authorize_complete_order.should be_true
        @invoice.order.user.transaction_ledgers.size.should == 2
        @invoice.capture_complete_order.should be_true
        @invoice.order.user.transaction_ledgers.size.should == 4
      end
      
      context 'cancel_authorized_payment' do
        it 'should create a CreditCardReceivePayment transaction then cancel' do
          @invoice.stubs(:amount).returns(20.50)      
          @invoice.authorize_complete_order
        
          @invoice.cancel_authorized_payment.should be_true
          @invoice.order.user.transaction_ledgers.size.should == 4
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
          revenue_credits.sum.should_not == 0
          ar_credits.sum.should_not == 0
          revenue_credits.sum.should  == revenue_debits.sum
          ar_credits.sum.should       == ar_debits.sum
        end
      end
    end
  end
end

describe Invoice, "#process_rma(return_amount, order)" do
  it 'should create a invoice for an RMA' do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    order = create(:order)
    invoice = Invoice.process_rma(20.55, order)
    #@invoice.stubs(:batches).returns([])
    #invoice.capture_complete_order.should be_true
    invoice.order.user.transaction_ledgers.size.should == 2
    invoice.state.should == 'refunded'
  end
end

describe Invoice, "Class methods" do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @invoice = create(:invoice)
  end

  describe Invoice, "#id_from_number(num)" do
    it 'should return invoice id' do
      invoice     = create(:invoice)
      invoice_id  = Invoice.id_from_number(invoice.number)
      invoice_id.should == invoice.id
    end
  end

  describe Invoice, "#find_by_number(num)" do
    it 'should find the invoice by number' do
      invoice = create(:invoice)
      find_invoice = Invoice.find_by_number(invoice.number)
      find_invoice.id.should == invoice.id
    end
  end
end
#def Invoice.generate(order_id, charge_amount)
#  Invoice.new(:order_id => order_id, :amount => charge_amount, :invoice_type => PURCHASE)
#end

describe Invoice, "#generate(order_id, charge_amount)" do
  it 'should find the invoice by number' do
    #invoice = create(:invoice)
    charge_amount = 20.15
    invoice = Invoice.generate(1, charge_amount)
    invoice.id.should == nil
    invoice.invoice_type.should == Invoice::PURCHASE
    invoice.valid?.should be_true
  end
end
describe Invoice, 'optimize' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end
  describe Invoice, ".unique_order_number" do
    it 'should return a unique_order_number' do
      invoice = create(:invoice)
      invoice.send(:unique_order_number).length.should > 8
    end
  end

  describe Invoice, ".authorization_reference" do
    it 'will return a confirmation id if there is a successful payment' do
      invoice = create(:invoice)
      payment = create(:payment, :invoice => invoice, :action => 'authorization', :success => true, :confirmation_id => 'good')
      invoice.authorization_reference.should == payment.confirmation_id
    end 
  end

  describe Invoice, ".succeeded?" do
    it 'will return a true if authorized or paid' do
      invoice = create(:invoice, :state => 'authorized')
      invoice.succeeded?.should be_true
      
      invoice = create(:invoice, :state => 'paid')
      invoice.succeeded?.should be_true
    end
  end
end

describe Invoice, ".integer_amount" do
  it 'should reprent the dollar amount in integer form' do
    invoice = create(:invoice, :amount => 13.56)
    invoice.integer_amount.should == 1356
  end
end


#def authorize_payment(credit_card, options = {})
#  options[:number] ||= unique_order_number
#  transaction do
#    authorization = Payment.authorize(integer_amount, credit_card, options)
#    payments.push(authorization)
#    if authorization.success?
#      payment_authorized!
#      authorize_complete_order
#    else
#      transaction_declined!
#    end
#    authorization
#  end
#end

describe Invoice, ".authorize_payment(credit_card, options = {})" do
  pending "test for authorize_payment(credit_card, options = {})"
end

#def capture_payment(options = {})
#  transaction do
#    capture = Payment.capture(integer_amount, authorization_reference, options)
#    payments.push(capture)
#    if capture.success?
#      payment_captured!
#      capture_complete_order
#    else
#      transaction_declined!
#    end
#    capture
#  end
#end

describe Invoice, ".capture_payment(options = {})" do
  pending "test for capture_payment(options = {})"
end

describe Invoice, ".user_id" do 
  it 'should give the orders user_id' do
    invoice = create(:invoice)
    invoice.user_id.should == invoice.order.user_id
  end
end

describe Invoice, ".user" do
  it 'should give the orders user_id' do
    invoice = create(:invoice)
    invoice.user.id.should == invoice.order.user.id
  end
end
