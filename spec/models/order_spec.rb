require 'spec_helper'

describe Order, "instance methods" do
  before(:each) do
    User.any_instance.stubs(:subscribe_to_newsletters).returns(true)
    User.any_instance.stubs(:set_referral_registered_at).returns(true)
    @order = FactoryGirl.create(:order)
  end

  context 'no need for store credits' do
    before(:each) do
      User.any_instance.stubs(:start_store_credits).returns(true)
    end

    context ".name" do
      it 'should return the users name' do
        user = FactoryGirl.create(:user)
        user.stubs(:name).returns('Freddy Boy')
        order = FactoryGirl.create(:order, user: user)
        expect(order.name).to eq 'Freddy Boy'
      end
    end

    context ".display_completed_at(format = :us_date)" do
      it 'should return the completed date in us format' do
        @order.stubs(:completed_at).returns(Time.zone.parse('2010-03-20 14:00:00'))
        expect(@order.display_completed_at).to eq '03/20/2010'
      end

      it 'should return "Not Finished."' do
        @order.stubs(:completed_at).returns(nil)
        expect(@order.display_completed_at).to eq "Not Finished."
      end
    end

    context ".first_invoice_amount" do
      it 'should return ""' do
        @order.stubs(:completed_invoices).returns([])
        expect(@order.first_invoice_amount).to eq ""
      end
      it 'should return "Not Finished."' do
        @invoice = FactoryGirl.create(:invoice, :amount => 13.49)
        @order.stubs(:completed_invoices).returns([@invoice])
        expect(@order.first_invoice_amount).to eq 13.49
      end
    end

    context ".cancel_unshipped_order(invoice)" do
      it 'should return ""' do
        @invoice = FactoryGirl.create(:invoice, :amount => 13.49)
        @order   = FactoryGirl.create(:order)
        @invoice.stubs(:cancel_authorized_payment).returns(true)
        expect(@order.cancel_unshipped_order(@invoice)).to be true
        expect(@order.active).to be false
      end
    end

    context ".status" do
      it 'should return "payment_declined"' do
        @invoice = FactoryGirl.create(:invoice, :state => 'payment_declined')
        @order.stubs(:invoices).returns([@invoice])
        expect(@order.status).to eq 'payment_declined'
      end
      it 'should return "not processed"' do
        @order.stubs(:invoices).returns([])
        expect(@order.status).to eq 'not processed'
      end
    end
  end

  context ".@order.credited_total" do

    it 'should calculate credited_total' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      tax_rate   = FactoryGirl.create(:tax_rate, :percentage => 10.0 )
      order_item = FactoryGirl.create(:order_item, :total => 5.52, :tax_rate => tax_rate )

      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)

      # shippping == 100
      # items     == 11.04
      # taxes     == 11.04 * .10 == 1.10
      # credits   == 10.02
      # total     == 112.14 - 10.02 = 102.12
      @order.user.store_credit.amount = 10.02
      @order.user.store_credit.save

      expect(@order.credited_total).to eq 102.12
    end

    it 'should calculate credited_total' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = FactoryGirl.create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(10.00)


      @order.user.store_credit.amount = 100.02
      @order.user.store_credit.save

      expect(@order.credited_total).to eq 0.0
    end
  end

  context ".@order.remove_user_store_credits" do
    it 'should remove store_credits.amount' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      order_item = FactoryGirl.create(:order_item, :total => 5.52 )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)
      #expect(@order.find_total).to eq 111.04


      @order.user.store_credit.amount = 15.52
      @order.user.store_credit.save
      @order.remove_user_store_credits
      store_credit = StoreCredit.find(@order.user.store_credit.id)
      expect(store_credit.amount).to eq 0.0
    end

    it 'should calculate credited_total with a coupon' do
      user   = FactoryGirl.create(:user)
      coupon = FactoryGirl.create(:coupon, :amount => 15.00, :expires_at => (Time.zone.now + 1.days), :starts_at => (Time.zone.now - 1.days) )
      order  = FactoryGirl.create(:order, :user => user, :coupon => coupon)

      order.stubs(:calculate_totals).returns( true )
      order.stubs(:calculated_at).returns(nil)

      tax_rate    = FactoryGirl.create(:tax_rate, :percentage => 10.0 )
      order_item1 = FactoryGirl.create(:order_item, :price => 20.00, :total => 20.00, :tax_rate => tax_rate, :order => order )
      order_item2 = FactoryGirl.create(:order_item, :price => 20.00, :total => 20.00, :tax_rate => tax_rate, :order => order )

      #@order.stubs(:order_items).returns([order_item1, order_item2])
      order.stubs(:coupon).returns(coupon)
      order.stubs(:shipping_charges).returns(100.00)

      # shippping == 100
      # items     == 40.00
      # taxes     == (40.00 - 15.00) * .10 == 2.50
      # credits   == 10.02
      # total     == 142.50 - 10.02 = 131.48
      # total - coupon     == 133.98 - 15.00 = 117.48
      order.user.store_credit.amount = 10.02
      order.user.store_credit.save
      order.reload
      expect(order.credited_total).to eq 117.48
    end

    it 'should remove store_credits.amount' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      tax_rate   = FactoryGirl.create(:tax_rate, :percentage => 10.0 )
      order_item = FactoryGirl.create(:order_item, :total => 5.52, :tax_rate => tax_rate )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(5.00)
      # shippping ==                5.00
      # items     ==               11.04
      # taxes     == 11.04 * .10 == 1.10
      # total     ==               17.14
      # expect(@order.find_total).to eq 17.14


      @order.user.store_credit.amount = 116.05
      @order.user.store_credit.save
      @order.remove_user_store_credits
      store_credit = StoreCredit.find(@order.user.store_credit.id)
      expect(store_credit.amount).to eq 98.91
    end
  end

  context ".capture_invoice(invoice)" do
    it 'should return an payment object' do
      ##  Create fake admin_cart object in memcached
      @invoice  = FactoryGirl.create(:invoice)
      payment   = @order.capture_invoice(@invoice)
      expect(payment.class.to_s).to eq 'Payment'
      expect(@invoice.state).to     eq 'paid'
    end
  end



  #def create_invoice(credit_card, charge_amount, args)
  #  transaction do
  #    create_invoice_transaction(credit_card, charge_amount, args)
  #  end
  #end
  context ".create_invoice(credit_card, charge_amount, args)" do
    it 'should return an create_invoice on success' do
      notifier_mock = mock()
      notifier_mock.stubs(:deliver)
      Notifier.stubs(:order_confirmation).returns(notifier_mock)
      cc_params = {
        :brand               => 'visa',
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
      expect(invoice.class.to_s).to eq 'Invoice'
      expect(invoice.state).to      eq 'authorized'
    end
    it 'should return an create_invoice on failure' do
      cc_params = {
        :brand               => 'visa',
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
      expect(invoice.class.to_s).to eq 'Invoice'
      expect(invoice.state).to      eq 'payment_declined'
    end
  end

  ##  this method is exersized by create_invoice method  TESTED
  context ".create_invoice_transaction(credit_card, charge_amount, args)"

  context ".order_complete!" do
    it  "should set completed_at and update the state" do
      @order.stubs(:update_inventory).returns(true)
      @order.completed_at = nil
      @order.order_complete!
      expect(@order.state).to eq 'complete'
      expect(@order.completed_at).not_to be nil
    end
  end

  context ".update_tax_rates" do
    it 'should set the beginning address id after find' do
      order_item = FactoryGirl.create(:order_item)
      tax_rate   = FactoryGirl.create(:tax_rate, :percentage => 5.5 )
      @order.ship_address_id = FactoryGirl.create(:address).id
      Product.any_instance.stubs(:tax_rate).returns(tax_rate)
      @order.stubs(:order_items).returns([order_item])
      @order.send(:update_tax_rates)
      expect(@order.order_items.first.tax_rate).to eq tax_rate
    end
  end

  context ".calculate_totals(force = false)" do
    it 'should set the beginning address id after find' do
      #@order.stubs(:calculated_at).returns(nil)
      order_item = FactoryGirl.create(:order_item)
      @order.stubs(:order_items).returns([order_item])
      @order.calculated_at = nil
      @order.total = nil
      @order.calculate_totals
      expect(@order.total).not_to be_nil
    end
  end
#
#shipping_charges

  context ".find_total(force = false)" do
    it 'should calculate the order totals with shipping charges' do
      @order.stubs(:calculate_totals).returns( true )
      @order.stubs(:calculated_at).returns(nil)
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0 )
      order_item = FactoryGirl.create(:order_item, :total => 5.52, :tax_rate => tax_rate )
      @order.stubs(:order_items).returns([order_item, order_item])
      @order.stubs(:shipping_charges).returns(100.00)
      # shippping == 100
      # items     == 11.04
      # taxes     == 11.04 * .10 == 1.10
      # credits   == 0.0
      # total     == 112.14  =  111.84
      expect(@order.find_total).to eq 112.14
    end
  end

  context ".ready_to_checkout?" do
    it 'should be ready to checkout' do
      order_item = FactoryGirl.create(:order_item )
      order_item.stubs(:ready_to_calculate?).returns(true)
      @order.stubs(:order_items).returns([order_item, order_item])
      expect(@order.ready_to_checkout?).to eq true
    end

    it 'should not be ready to checkout' do
      order_item = FactoryGirl.create(:order_item )
      order_item.stubs(:ready_to_calculate?).returns(false)
      @order.stubs(:order_items).returns([order_item, order_item])
      expect(@order.ready_to_checkout?).to eq false
    end
  end

  context ".shipping_charges" do
    it 'should return one shippoing rate that all items fall under' do
        order_item = FactoryGirl.create(:order_item )
        ShippingRate.any_instance.stubs(:individual?).returns(false)
        ShippingRate.any_instance.stubs(:rate).returns(1.01)

        OrderItem.stubs(:order_items_in_cart).returns( [order_item, order_item] )

        expect(@order.shipping_charges).to eq 1.01
    end

    it 'should return one shipping rate that all items fall under' do
        order_item = FactoryGirl.create(:order_item )
        ShippingRate.any_instance.stubs(:individual?).returns(true)
        ShippingRate.any_instance.stubs(:rate).returns(1.01)

        OrderItem.stubs(:order_items_in_cart).returns( [order_item, order_item] )

        expect(@order.shipping_charges).to eq 2.02
    end
  end

  context ".add_items(variant, quantity, state_id = nil)" do
    it 'should add a new variant to order items ' do
      variant = FactoryGirl.create(:variant)
      order_items_size = @order.order_items.size
      @order.add_items(variant, 2)
      expect(@order.order_items.size).to eq order_items_size + 2
    end
  end

  context ".remove_items(variant, final_quantity)" do
    it 'should remove variant from order items ' do
      variant = FactoryGirl.create(:variant)
      order_items_size = @order.order_items.size
      @order.add_items(variant, 3)
      @order.remove_items(variant, 1)
      expect(@order.order_items.size).to eq order_items_size + 1
    end
  end

  context ".set_email" do
    #self.email = user.email if user_id
    it 'should set the email address if there is a user_id' do
      @order.email = nil
      @order.send(:set_email)
      expect(@order.email).not_to be_nil
      expect(@order.email).to eq @order.user.email
    end
    it 'should not set the email address if there is a user_id' do
      @order.email = nil
      @order.user_id = nil
      @order.send(:set_email)
      expect(@order.email).to be_nil
    end
  end

  context ".set_number" do
    it 'should set number' do
      @order.send(:set_number)
      expect(@order.number).to eq (Order::NUMBER_SEED + @order.id).to_s(Order::CHARACTERS_SEED)
    end

    it 'should set number not to be nil' do
      order = FactoryGirl.build(:order)
      order.send(:set_number)
      expect(order.number).not_to be_nil
    end
  end

  context ".set_order_number" do
    it 'should set number ' do
      order = FactoryGirl.create(:order)
      order.number = nil
      order.send(:set_order_number)
      expect(order.number).not_to be_nil
    end
  end

  context ".save_order_number" do
    it 'should set number and save' do
      order = FactoryGirl.create(:order)
      order.number = nil
      expect(order.send(:save_order_number)).to be true
      expect(order.number).not_to eq (Order::NUMBER_SEED + @order.id).to_s(Order::CHARACTERS_SEED)
    end
  end

  context ".update_inventory" do
    #self.order_items.each {|item| item.variant.add_pending_to_customer(1) }
    it 'should call add_pending_to_customer for each variant' do
      variant     = mock()#create(:variant )
      order_item  = FactoryGirl.create(:order_item)
      order_item.stubs(:variant).returns(variant)
      @order.order_items.push([order_item])
      variant.expects(:add_pending_to_customer).once
      @order.update_inventory
    end
  end

  context ".variant_ids" do
    #order_items.collect{|oi| oi.variant_id }
    it 'should return each  variant_id' do
      variant     = FactoryGirl.create(:variant )
      order_item  = FactoryGirl.create(:order_item)
      order_item.stubs(:variant_id).returns(variant.id)
      @order.stubs(:order_items).returns([order_item, order_item])
      expect(@order.variant_ids).to eq [variant.id, variant.id]
    end
  end

  context ".has_shipment?" do
    #shipments_count > 0
    it 'should return false' do
      expect(@order.has_shipment?).to be false
    end
    it 'should return true' do
      FactoryGirl.create(:shipment, :order => @order)
      expect(Order.find(@order.id).has_shipment?).to be true
    end
  end

  context ".create_shipments_with_order_item_ids(order_item_ids)" do
    it "should return false if there aren't any ids" do
      @order_item = FactoryGirl.create(:order_item, :order => @order)
      expect(@order.create_shipments_with_order_item_ids([])).to be false
    end
    it "should return false if the ids cant be shipped" do
      @order_item = FactoryGirl.create(:order_item, :order => @order, :state => 'unpaid')
      expect(@order.create_shipments_with_order_item_ids([@order_item.id])).to be false
    end
    it "should return true if the ids can be shipped" do
      @order_item = FactoryGirl.build(:order_item, :order => @order)
      @order_item.state = 'paid'
      @order_item.save
      expect(@order.create_shipments_with_order_item_ids([@order_item.id])).to be true
    end
  end

  context '.item_prices' do

    it 'should return an Array of prices' do
      order_item1 = FactoryGirl.create(:order_item, :order => @order, :price => 2.01)
      order_item2 = FactoryGirl.create(:order_item, :order => @order, :price => 9.00)
      @order.stubs(:order_items).returns([order_item1, order_item2])
      expect(@order.send(:item_prices).class).to eq Array
      expect(@order.send(:item_prices).include?(2.01)).to be true
      expect(@order.send(:item_prices).include?(9.00)).to be true
    end
  end


  context '.coupon_amount' do

    it 'should return 0.0 for no coupon' do
      @order.stubs(:coupon_id).returns(nil)
      expect(@order.coupon_amount).to eq 0.0
    end

    it 'should return call coupon.value' do
      coupon  = FactoryGirl.create(:coupon_value)
      order   = FactoryGirl.create(:order, :coupon => coupon)
      order.stubs(:coupon_id).returns(2)
      order.coupon.expects(:value).once
      order.coupon_amount
    end
  end

end

RSpec.describe Order do
  before(:each) do
    User.any_instance.stubs(:subscribe_to_newsletters).returns(true)
    User.any_instance.stubs(:start_store_credits).returns(true)
    User.any_instance.stubs(:set_referral_registered_at).returns(true)

    @order = FactoryGirl.create(:order)

    @tax_rate    = FactoryGirl.create(:tax_rate, :percentage => 10.0)
    @tax_rate5   = FactoryGirl.create(:tax_rate, :percentage => 5.0)
    @order_item  = FactoryGirl.create(:order_item, :tax_rate => @tax_rate,  :price => 20.00, order: @order)
    @order_item5 = FactoryGirl.create(:order_item, :tax_rate => @tax_rate5, :price => 10.00, order: @order)

  end

  describe "Without VAT" do
    before(:each) do
      Settings.vat = false
    end

    context ".tax_charges" do
      it 'should return one tax_charges for all order items' do
        @order.stubs(:order_items).returns( [@order_item, @order_item5] )
        expect(@order.tax_charges).to eq [2.00 , 0.50]
        expect(@order.total_tax_charges).to eq 2.50
      end
    end

    context ".total_tax_charges" do
      it 'should return one tax_charges for all order items' do
        @order.stubs(:order_items).returns( [@order_item, @order_item5] )
        expect(@order.total_tax_charges).to eq 2.50
      end
    end
  end

  context "With VAT" do
    before(:each) do
      Settings.vat = true
    end

    context ".tax_charges" do
      it 'should return tax_charges for all order items' do
        @order.stubs(:order_items).returns( [@order_item, @order_item5] )
        expect(@order.tax_charges).to eq [0.00 , 0.00]
      end
    end

    context ".total_tax_charges" do
      it 'should return one tax_charges for all order items' do
        @order.stubs(:order_items).returns( [@order_item, @order_item5] )
        expect(@order.total_tax_charges).to eq 0.00
      end
    end
  end
end

describe Order, "#find_myaccount_details" do
  it 'should return have invoices and completed_invoices associations' do
    @order = FactoryGirl.create(:order)
    expect(@order.completed_invoices).to eq []
    expect(@order.invoices).to           eq []
  end
end

describe Order, "#id_from_number(num)" do
  it 'should return the order id' do
    order     = FactoryGirl.create(:order)
    order_id  = Order.id_from_number(order.number)
    expect(order_id).to eq order.id
  end
end

describe Order, "#find_by_number(num)" do
  it 'should find the order by number' do
    order = FactoryGirl.create(:order)
    find_order = Order.find_by_number(order.number)
    expect(find_order.id).to eq order.id
  end
end


describe Order, "#find_finished_order_grid(params = {})", type: :model do
  it "should return finished Orders " do
    order1 = FactoryGirl.create(:order, :completed_at => nil)
    order2 = FactoryGirl.create(:order, :completed_at => Time.now)
    admin_grid = Order.find_finished_order_grid
    expect(admin_grid.size).to eq 1
    expect(admin_grid.include?(order1)).to be false
    expect(admin_grid.include?(order2)).to be true
  end
end

describe Order, "#fulfillment_grid(params = {})" do
  it "should return Orders " do
    order1 = FactoryGirl.create(:order, :shipped => false)
    order2 = FactoryGirl.create(:order, :shipped => true)
    admin_grid = Order.fulfillment_grid
    expect(admin_grid.size).to eq 1
    expect(admin_grid.include?(order1)).to be true
    expect(admin_grid.include?(order2)).to be false
  end
end
