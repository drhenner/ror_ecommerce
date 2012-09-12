require 'spec_helper'

describe Order, "instance methods" do
  before(:each) do
    @user = create(:user)
    @user.stubs(:name).returns('Freddy Boy')
    @order = create(:order, :user => @user)
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
      @invoice = create(:invoice, :amount => 13.49)
      @order.stubs(:completed_invoices).returns([@invoice])
      @order.first_invoice_amount.should == 13.49
    end
  end

  context ".cancel_unshipped_order(invoice)" do
    it 'should return ""' do
      @invoice = create(:invoice, :amount => 13.49)
      @order = create(:order)
      @invoice.stubs(:cancel_authorized_payment).returns(true)
      @order.cancel_unshipped_order(@invoice).should == true
      @order.active.should be_false
    end
  end

  context ".status" do
    it 'should return "payment_declined"' do
      @invoice = create(:invoice, :state => 'payment_declined')
      @order.stubs(:invoices).returns([@invoice])
      @order.status.should == 'payment_declined'
    end
    it 'should return "not processed"' do
      @order.stubs(:invoices).returns([])
      @order.status.should == 'not processed'
    end
  end

  context ".@order.credited_total" do

    it 'should calculate credited_total' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)


      @order.user.store_credit.amount = 10.02
      @order.user.store_credit.save

      @order.credited_total.should == 101.02
    end

    it 'should calculate credited_total' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(10.00)


      @order.user.store_credit.amount = 100.02
      @order.user.store_credit.save

      @order.credited_total.should == 0.0
    end
  end

  context ".@order.remove_user_store_credits" do
    it 'should remove store_credits.amount' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)
      #@order.find_total.should == 111.04


      @order.user.store_credit.amount = 15.52
      @order.user.store_credit.save
      @order.remove_user_store_credits
      store_credit = StoreCredit.find(@order.user.store_credit.id)
      store_credit.amount.should == 0.0
    end

    it 'should remove store_credits.amount' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(5.00)
      #@order.find_total.should == 16.04


      @order.user.store_credit.amount = 116.05
      @order.user.store_credit.save
      @order.remove_user_store_credits
      store_credit = StoreCredit.find(@order.user.store_credit.id)
      store_credit.amount.should == 100.01
    end
  end

  context ".capture_invoice(invoice)" do
    it 'should return an payment object' do
      ##  Create fake admin_cart object in memcached
      @invoice  = create(:invoice)
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

  ##  this method is exersized by create_invoice method  TESTED
  context ".create_invoice_transaction(credit_card, charge_amount, args)"

  context ".order_complete!" do
    it  "should set completed_at and update the state" do
      @order.stubs(:update_inventory).returns(true)
      @order.completed_at = nil
      @order.order_complete!
      @order.state.should == 'complete'
      @order.completed_at.should_not == nil
    end
  end

  context ".update_tax_rates" do
    it 'should set the beginning address id after find' do
      order_item = create(:order_item)
      tax_rate   = create(:tax_rate, :percentage => 5.5 )
      @order.ship_address_id = create(:address).id
      Product.any_instance.stubs(:tax_rate).returns(tax_rate)
      @order.stubs(:order_items).returns([order_item])
      @order.send(:update_tax_rates)
      @order.order_items.first.tax_rate.should == tax_rate
    end
  end

  context ".calculate_totals(force = false)" do
    it 'should set the beginning address id after find' do
      #@order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item)
      @order.stubs(:order_items).returns([order_item])
      @order.calculated_at = nil
      @order.total = nil
      @order.calculate_totals
      @order.total.should_not be_nil
    end
  end
#
#shipping_charges

  context ".find_total(force = false)" do
    it 'should calculate the order totals with shipping charges' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)
      @order.find_total.should == 111.04
    end
  end

  context ".ready_to_checkout?" do
    it 'should be ready to checkout' do
      order_item = create(:order_item )
      order_item.stubs(:ready_to_calculate?).returns(true)
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.ready_to_checkout?.should == true
    end

    it 'should not be ready to checkout' do
      order_item = create(:order_item )
      order_item.stubs(:ready_to_calculate?).returns(false)
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.ready_to_checkout?.should == false
    end
  end

  context ".shipping_charges" do
    it 'should return one shippoing rate that all items fall under' do
        order_item = create(:order_item )
        ShippingRate.any_instance.stubs(:individual?).returns(false)
        ShippingRate.any_instance.stubs(:rate).returns(1.01)

        OrderItem.stubs(:order_items_in_cart).returns( [order_item, order_item] )

        @order.shipping_charges.should == 1.01
    end

    it 'should return one shipping rate that all items fall under' do
        order_item = create(:order_item )
        ShippingRate.any_instance.stubs(:individual?).returns(true)
        ShippingRate.any_instance.stubs(:rate).returns(1.01)

        OrderItem.stubs(:order_items_in_cart).returns( [order_item, order_item] )

        @order.shipping_charges.should == 2.02
    end
  end

  context ".add_items(variant, quantity, state_id = nil)" do
    it 'should add a new variant to order items ' do
      variant = create(:variant)
      order_items_size = @order.order_items.size
      @order.add_items(variant, 2)
      @order.order_items.size.should == order_items_size + 2
    end
  end

  context ".remove_items(variant, final_quantity)" do
    it 'should remove variant from order items ' do
      variant = create(:variant)
      order_items_size = @order.order_items.size
      @order.add_items(variant, 3)
      @order.remove_items(variant, 1)
      @order.order_items.size.should == order_items_size + 1
    end
  end

  context ".set_email" do
    #self.email = user.email if user_id
    it 'should set the email address if there is a user_id' do
      @order.email = nil
      @order.send(:set_email)
      @order.email.should_not be_nil
      @order.email.should == @order.user.email
    end
    it 'should not set the email address if there is a user_id' do
      @order.email = nil
      @order.user_id = nil
      @order.send(:set_email)
      @order.email.should be_nil
    end
  end

  context ".set_number" do
    it 'should set number' do
      @order.send(:set_number)
      @order.number.should == (Order::NUMBER_SEED + @order.id).to_s(Order::CHARACTERS_SEED)
    end

    it 'should set number not to be nil' do
      order = build(:order)
      order.send(:set_number)
      order.number.should_not be_nil
    end
  end

  context ".set_order_number" do
    it 'should set number ' do
      order = create(:order)
      order.number = nil
      order.send(:set_order_number)
      order.number.should_not be_nil
    end
  end

  context ".save_order_number" do
    it 'should set number and save' do
      order = create(:order)
      order.number = nil
      order.send(:save_order_number).should be_true
      order.number.should_not == (Order::NUMBER_SEED + @order.id).to_s(Order::CHARACTERS_SEED)
    end
  end

  context ".update_inventory" do
    #self.order_items.each {|item| item.variant.add_pending_to_customer(1) }
    it 'should call add_pending_to_customer for each variant' do
      variant     = mock()#create(:variant )
      order_item  = create(:order_item)
      order_item.stubs(:variant).returns(variant)
      @order.order_items.push([order_item])
      variant.expects(:add_pending_to_customer).once
      @order.update_inventory
    end
  end

  context ".variant_ids" do
    #order_items.collect{|oi| oi.variant_id }
    it 'should return each  variant_id' do
      variant     = create(:variant )
      order_item  = create(:order_item)
      order_item.stubs(:variant_id).returns(variant.id)
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.variant_ids.should == [variant.id, variant.id]
    end
  end

  context ".has_shipment?" do
    #shipments_count > 0
    it 'should return false' do
      @order.has_shipment?.should be_false
    end
    it 'should return true' do
      create(:shipment, :order => @order)
      Order.find(@order.id).has_shipment?.should be_true
    end
  end

  context '.item_prices' do

    it 'should return an Array of prices' do
      order_item1 = create(:order_item, :order => @order, :price => 2.01)
      order_item2 = create(:order_item, :order => @order, :price => 9.00)
      @order.stubs(:order_items).returns([order_item1, order_item2])
      @order.send(:item_prices).class.should == Array
      @order.send(:item_prices).include?(2.01).should be_true
      @order.send(:item_prices).include?(9.00).should be_true
    end
  end


  context '.coupon_amount' do

    it 'should return 0.0 for no coupon' do
      @order.stubs(:coupon_id).returns(nil)
      @order.coupon_amount.should == 0.0
    end

    it 'should return call coupon.value' do
      coupon  = create(:coupon_value)
      order   = create(:order, :coupon => coupon)
      order.stubs(:coupon_id).returns(2)
      order.coupon.expects(:value).once
      order.coupon_amount
    end
  end

end

describe Order, "Without VAT" do
  before(:each) do
    @order = create(:order)
  end

  before(:all) do
    Settings.vat = false
  end

  context ".tax_charges" do
    it 'should return one tax_charges for all order items' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      tax_rate5 = create(:tax_rate, :percentage => 5.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item5 = create(:order_item, :tax_rate => tax_rate5, :price => 10.00)

      @order.stubs(:order_items).returns( [order_item, order_item5] )
      @order.tax_charges.should == [2.00 , 0.50]
    end
  end

  context ".total_tax_charges" do
    it 'should return one tax_charges for all order items' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      tax_rate5 = create(:tax_rate, :percentage => 5.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item5 = create(:order_item, :tax_rate => tax_rate5, :price => 10.00)

      @order.stubs(:order_items).returns( [order_item, order_item5] )
      @order.total_tax_charges.should == 2.50
    end
  end
end

describe Order, "With VAT" do
  before(:each) do
    @order = create(:order)
  end
  before(:all) do
    Settings.vat = true
  end

  context ".tax_charges" do
    it 'should return one tax_charges for all order items' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      tax_rate5 = create(:tax_rate, :percentage => 5.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item5 = create(:order_item, :tax_rate => tax_rate5, :price => 10.00)

      @order.stubs(:order_items).returns( [order_item, order_item5] )
      @order.tax_charges.should == [0.00 , 0.00]
    end
  end

  context ".total_tax_charges" do
    it 'should return one tax_charges for all order items' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      tax_rate5 = create(:tax_rate, :percentage => 5.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item5 = create(:order_item, :tax_rate => tax_rate5, :price => 10.00)

      @order.stubs(:order_items).returns( [order_item, order_item5] )
      @order.total_tax_charges.should == 0.00
    end
  end
end

describe Order, "#find_myaccount_details" do
  it 'should return have invoices and completed_invoices associations' do
    @order = create(:order)
    @order.completed_invoices.should == []
    @order.invoices.should == []
  end
end

describe Order, "#new_admin_cart(admin_cart, args = {})" do
  before(:each) do
    @variant = create(:variant)
    @shipping_rate = create(:shipping_rate)
    @tax_rate = create(:tax_rate)


    @admin_cart = {}
    @admin_cart[:shipping_address] = create(:address)
    @admin_cart[:billing_address]  = create(:address)
    @admin_cart[:user]             = create(:user)
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

describe Order, "#id_from_number(num)" do
  it 'should return the order id' do
    order     = create(:order)
    order_id  = Order.id_from_number(order.number)
    order_id.should == order.id
  end
end

describe Order, "#find_by_number(num)" do
  it 'should find the order by number' do
    order = create(:order)
    find_order = Order.find_by_number(order.number)
    find_order.id.should == order.id
  end
end


describe Order, "#find_finished_order_grid(params = {})" do
  it "should return finished Orders " do
    order1 = create(:order, :completed_at => nil)
    order2 = create(:order, :completed_at => Time.now)
    admin_grid = Order.find_finished_order_grid
    admin_grid.size.should == 1
    admin_grid.include?(order1).should be_false
    admin_grid.include?(order2).should be_true
  end
end

describe Order, "#fulfillment_grid(params = {})" do
  it "should return Orders " do
    order1 = create(:order, :shipped => false)
    order2 = create(:order, :shipped => true)
    admin_grid = Order.fulfillment_grid
    admin_grid.size.should == 1
    admin_grid.include?(order1).should be_true
    admin_grid.include?(order2).should be_false
  end
end
