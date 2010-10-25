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
end

describe Invoice, ".capture_complete_order" do
  pending "test for capture_complete_order"
end

describe Invoice, ".authorize_complete_order" do
  pending "test for authorize_complete_order"
end

describe Invoice, ".cancel_authorized_payment" do
  pending "test for cancel_authorized_payment"
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
