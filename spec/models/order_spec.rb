require 'spec_helper'

describe Order, "instance methods" do
  before(:each) do 
    @user = Factory(:user)
    @user.stubs(:name).returns('Freddy Boy')
    @order = Factory(:order, :user => @user)
  end
  
  context ".name" do
    it 'should return the users name' do
      @order.name.should == 'Freddy Boy'
    end
  end

  context ".display_completed_at(format = :us_date)" do
    it 'should return the completed date in us format' do
      @order.stubs(:completed_at).returns(Time.zone.parse('2010-03-20 14:00:00'))
      @order.display_completed_at.should == '03/20/2010'
    end
    
    it 'should return "Not Finished."' do
      @order.stubs(:completed_at).returns(nil)
      @order.display_completed_at.should == "Not Finished."
    end
  end

  context ".first_invoice_amount" do
    it 'should return ""' do
      @order.stubs(:completed_invoices).returns([])
      @order.first_invoice_amount.should == ""
    end
    it 'should return "Not Finished."' do
      @invoice = Factory(:invoice, :amount => 13.49)
      @order.stubs(:completed_invoices).returns([@invoice])
      @order.first_invoice_amount.should == 13.49
    end
  end


  #def cancel_unshipped_order(invoice)
  #  transaction do
  #    self.update_attributes(:active => false)
  #    invoice.cancel_authorized_payment
  #  end
  #end

  context ".cancel_unshipped_order(invoice)" do
    it 'should return ""' do
      @invoice = Factory(:invoice, :amount => 13.49)
      @order = Factory(:order)
      @invoice.stubs(:cancel_authorized_payment).returns(true)
      @order.cancel_unshipped_order(@invoice).should == true
      @order.active.should be_false
    end
  end

  context ".status" do
    it 'should return "payment_declined"' do
      @invoice = Factory(:invoice, :state => 'payment_declined')
      @order.stubs(:invoices).returns([@invoice])
      @order.status.should == 'payment_declined'
    end
    it 'should return "not processed"' do
      @order.stubs(:invoices).returns([])
      @order.status.should == 'not processed'
    end
  end

end



describe Order, "#find_myaccount_details" do
  pending "test for find_myaccount_details"
end

describe Order, "#new_admin_cart(admin_cart, args = {})" do
  pending "test for new_admin_cart(admin_cart, args = {})"
end

describe Order, ".capture_invoice(invoice)" do
  pending "test for capture_invoice(invoice)"
end

describe Order, ".create_invoice(credit_card, charge_amount, args)" do
  pending "test for create_invoice(credit_card, charge_amount, args)"
end

describe Order, ".create_invoice_transaction(credit_card, charge_amount, args)" do
  pending "test for create_invoice_transaction(credit_card, charge_amount, args)"
end

describe Order, ".order_complete!" do
  pending "test for order_complete!"
end

describe Order, ".set_beginning_values" do
  pending "test for set_beginning_values"
end

describe Order, ".update_tax_rates" do
  pending "test for update_tax_rates"
end

describe Order, ".calculate_totals(force = false)" do
  pending "test for calculate_totals(force = false)"
end

describe Order, ".order_total(force = false)" do
  pending "test for order_total(force = false)"
end

describe Order, ".ready_to_checkout?" do
  pending "test for ready_to_checkout?"
end

describe Order, ".find_total(force = false)" do
  pending "test for find_total(force = false)"
end

describe Order, ".shipping_charges" do
  pending "test for shipping_charges"
end

describe Order, ".update_address(address_type_id , address_id)" do
  pending "test for update_address(address_type_id , address_id)"
end

describe Order, ".add_items(variant, quantity, state_id = nil)" do
  pending "test for add_items(variant, quantity, state_id = nil)"
end

describe Order, ".new_items(variant, quantity, state_id = nil)" do
  pending "test for new_items(variant, quantity, state_id = nil)"
end

describe Order, ".set_email" do
  pending "test for set_email"
end

describe Order, ".set_number" do
  pending "test for set_number"
end

describe Order, ".set_order_number" do
  pending "test for set_order_number"
end

describe Order, ".save_order_number" do
  pending "test for save_order_number"
end

describe Order, "#id_from_number(num)" do
  pending "test for id_from_number(num)"
end

describe Order, "#find_by_number(num)" do
  pending "test for find_by_number(num)"
end

describe Order, ".update_inventory" do
  pending "test for update_inventory"
end

describe Order, ".variant_ids" do
  pending "test for variant_ids"
end

describe Order, ".has_shipment?" do
  pending "test for has_shipment?"
end

describe Order, "#find_finished_order_grid(params = {})" do
  pending "test for find_finished_order_grid(params = {})"
end

describe Order, "#fulfillment_grid(params = {})" do
  pending "test for fulfillment_grid(params = {})"
end
