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

  context ".capture_invoice(invoice)" do
    it 'should return an payment object' do
      ##  Create fake admin_cart object in memcached
      @invoice  = Factory(:invoice)
      payment   = @order.capture_invoice(@invoice)
      payment.class.to_s.should == 'Payment'
      @invoice.state.should == 'paid'
    end
  end
  
  
  
  #def create_invoice(credit_card, charge_amount, args)
  #  transaction do 
  #    create_invoice_transaction(credit_card, charge_amount, args)
  #  end
  #end
  context ".create_invoice(credit_card, charge_amount, args)" do
    it 'should return an create_invoice on success' do
      cc_params = {
        :type               => 'visa',
        :number             => '1',
        :verification_value => '322',
        :month              => '4',
        :year               => '2010',
        :first_name         => 'Umang',
        :last_name          => 'Chouhan'
      }
      
      ##  Create fake admin_cart object in memcached
      # create_invoice(credit_card, charge_amount, args)
      credit_card               = ActiveMerchant::Billing::CreditCard.new(cc_params)
      invoice                   = @order.create_invoice(credit_card, 12.45, {})
      invoice.class.to_s.should == 'Invoice'
      invoice.state.should      == 'authorized'
    end
    it 'should return an create_invoice on failure' do
      cc_params = {
        :type               => 'visa',
        :number             => '2',
        :verification_value => '322',
        :month              => '4',
        :year               => '2010',
        :first_name         => 'Umang',
        :last_name          => 'Chouhan'
      }
      
      ##  Create fake admin_cart object in memcached
      # create_invoice(credit_card, charge_amount, args)
      credit_card               = ActiveMerchant::Billing::CreditCard.new(cc_params)
      invoice                   = @order.create_invoice(credit_card, 12.45, {})
      invoice.class.to_s.should == 'Invoice'
      invoice.state.should      == 'payment_declined'
    end
  end

end



describe Order, "#find_myaccount_details" do
  it 'should return have invoices and completed_invoices associations' do
    @order = Factory(:order)
    @order.completed_invoices.should == []
    @order.invoices.should == []
  end
end

#def self.new_admin_cart(admin_cart, args = {})
#  transaction do 
#    admin_order = Order.new(  :ship_address     => admin_cart[:shipping_address],
#                              :bill_address     => admin_cart[:billing_address],
#                              #:coupon           => admin_cart[:coupon],
#                              :email            => admin_cart[:user].email,
#                              :user             => admin_cart[:user],
#                              :ip_address       => args[:ip_address]
#                          )
#    admin_order.save
#    admin_cart[:order_items].each_pair do |variant_id, hash|
#        hash[:quantity].times do
#            item = OrderItem.new( :variant        => hash[:variant],
#                                  :tax_rate       => hash[:tax_rate],
#                                  :price          => hash[:variant].price,
#                                  :total          => hash[:total],
#                                  :shipping_rate  => hash[:shipping_rate]
#                              )
#            admin_order.order_items.push(item)
#        end
#    end
#    admin_order.save
#    admin_order
#  end
#end



describe Order, "#new_admin_cart(admin_cart, args = {})" do
  before(:each) do
    @variant = Factory(:variant)
    @shipping_rate = Factory(:shipping_rate)
    @tax_rate = Factory(:tax_rate)
    
    
    @admin_cart = {}
    @admin_cart[:shipping_address] = Factory(:address)
    @admin_cart[:billing_address]  = Factory(:address)
    @admin_cart[:user]             = Factory(:user)
    @admin_cart[:order_items]      = {
      @variant.id => {
        :quantity => 2,
        :variant  => @variant,
        :tax_rate       => @tax_rate,
        :price          => @variant.price,
        :total          => @variant.total_price(@tax_rate),
        :shipping_rate  => @shipping_rate
      }
    }
  end
  
  it 'should return an order object' do
    ##  Create fake admin_cart object in memcached
    args = {}
    args[:ip_address] = '123.09.09.133'
    order = Order.new_admin_cart(@admin_cart, args)
    order.class.to_s.should == 'Order'
    order.order_items.size.should == 2#quantity == 2 thus 2 order_items
  end
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
