require 'spec_helper'


describe Invoice, "requirements" do
  it 'should have constants' do
    Invoice::NUMBER_SEED.should > 10000 # this keeps the invoice # not so obvious
    Invoice::CHARACTERS_SEED.should > 9
  end
end

describe Invoice, "instance methods" do
  before(:each) do 
    @invoice = Factory(:invoice)
  end
  
  context '.number' do
    it 'should exist and not = id' do
      @invoice.number.should_not == @invoice.id
      @invoice.number.length.should > 3
    end
  end
  
  context ".capture_complete_order" do
    pending "these tests all can be more thorough... LIKE ensuring credit and debit add to 0"
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
          revenue_credits = ar_credits = revenue_debits = ar_debits = []
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
  pending "test for self.process_rma(return_amount, order)"
end

describe Invoice, "#id_from_number(num)" do
  pending "test for self.id_from_number(num)"
end

describe Invoice, "#find_by_number(num)" do
  pending "test for self.find_by_number(num)"
end

describe Invoice, "#generate(order_id, charge_amount)" do
  pending "test for Invoice.generate(order_id, charge_amount)"
end

describe Invoice, ".unique_order_number" do
  pending "test for unique_order_number"
end

describe Invoice, ".authorization_reference" do
  pending "test for authorization_reference"
end

describe Invoice, ".succeeded?" do
  pending "test for succeeded?"
end

describe Invoice, ".integer_amount" do
  pending "test for integer_amount"
end

describe Invoice, ".succeeded?" do
  pending "test for succeeded?"
end

describe Invoice, ".authorize_payment(credit_card, options = {})" do
  pending "test for authorize_payment(credit_card, options = {})"
end

describe Invoice, ".capture_payment(options = {})" do
  pending "test for capture_payment(options = {})"
end

describe Invoice, ".user_id" do
  pending "test for user_id"
end

describe Invoice, ".user" do
  pending "test for user"
end

describe Invoice, ".period" do
  pending "test for period"
end
