require 'spec_helper'

describe PurchaseOrder do
  before(:each) do
    @purchase_order = FactoryGirl.build(:purchase_order)
  end

  it "should be valid with minimum attribues" do
    expect(@purchase_order).to be_valid
  end
end

describe PurchaseOrder, ".display_received" do
  it "should return Yes when true" do
    order = FactoryGirl.build(:purchase_order)
    order.stubs(:state).returns('received')

    expect(order.display_received).to eq "Yes"
  end

  it "should return No when false" do
    order = FactoryGirl.build(:purchase_order)
    order.stubs(:state).returns('pending')

    expect(order.display_received).to eq "No"
  end
end

describe PurchaseOrder, ".display_estimated_arrival_on" do
  it "should return the correct name" do
    order = FactoryGirl.build(:purchase_order)
    now = Time.now
    order.stubs(:estimated_arrival_on).returns(now.to_date)

    expect(order.display_estimated_arrival_on).to eq I18n.localize(now, format: :us_date)
  end
end

describe PurchaseOrder, ".supplier_name" do
  it "should return the correct name" do
    order    = FactoryGirl.build(:purchase_order)
    supplier = FactoryGirl.build(:supplier)
    supplier.stubs(:name).returns("Supplier Test")
    order.stubs(:supplier).returns(supplier)

    expect(order.supplier_name).to eq "Supplier Test"
  end
end

describe PurchaseOrder, 'instance methods' do
  before(:each) do
    @purchase_order = FactoryGirl.create(:purchase_order, :state => 'pending')
    @purchase_order.purchase_order_variants.push(create(:purchase_order_variant, :purchase_order => @purchase_order, :is_received => false))
  end

  context ".receive_po=(answer)" do
    it 'should call receive_variants' do
      @purchase_order.expects(:receive_variants).once
      @purchase_order.receive_po=('1')
    end

    it 'should call receive_variants' do
      @purchase_order.expects(:receive_variants).once
      @purchase_order.receive_po=('true')
    end

    it 'should not call receive_variants' do
      @purchase_order.expects(:receive_variants).never
      @purchase_order.receive_po=('0')
    end

    it 'should not call receive_variants' do
      @purchase_order.state = 'received'
      @purchase_order.expects(:receive_variants).never
      @purchase_order.receive_po=('1')
    end
  end

  context ".receive_po" do
    it 'should return true if state is received' do
      @purchase_order.state = PurchaseOrder::RECEIVED
      expect(@purchase_order.receive_po).to be true
    end

    it 'should return false if state is not received' do
      @purchase_order.state = PurchaseOrder::PENDING
      expect(@purchase_order.receive_po).to be false
    end
  end

  context ".display_tracking_number" do
    it 'should display N/A if the tracking number is nil' do
      @purchase_order.tracking_number = nil
      expect(@purchase_order.display_tracking_number).to eq 'N/A'
    end
  end

  #context '.total_cost' do
  #  it 'should return the total'
  #end
end

describe PurchaseOrder, ".pay_for_order" do
  it 'should pay for the order ' do
    purchase_order = FactoryGirl.create(:purchase_order, :state => 'pending', :total_cost => 20.32)
    expect(purchase_order.pay_for_order).to be true
    expect(purchase_order.transaction_ledgers.size).to eq 2

    #cash_debits = cash_credits = expense_debits = expense_credits = []
    cash_debits = []
    cash_credits = []
    expense_debits = []
    expense_credits = []
    purchase_order.transaction_ledgers.each do |ledger|
      if ledger.transaction_account_id == TransactionAccount::EXPENSE_ID
        expense_credits << ledger.credit
        expense_debits  << ledger.debit
      end
      if ledger.transaction_account_id == TransactionAccount::CASH_ID
        cash_credits << ledger.credit
        cash_debits  << ledger.debit
      end
    end
    ## credits and debits should cancel themselves out

    expect(expense_credits.sum).to  eq 0.0
    expect(expense_debits.sum).to   eq 20.32
    expect(cash_credits.sum).to     eq expense_debits.sum
    expect(cash_debits.sum).to      eq expense_credits.sum

  end

end

describe PurchaseOrder, ".receive_variants" do
  it 'should receive PO_varaints ' do
    purchase_order = FactoryGirl.create(:purchase_order, :state => 'pending')
    purchase_order.purchase_order_variants.push(create(:purchase_order_variant, :purchase_order => purchase_order, :is_received => false))
    PurchaseOrderVariant.any_instance.expects(:receive!).once
    purchase_order.receive_variants
  end

  it 'should not receive PO_varaints ' do
    purchase_order = FactoryGirl.create(:purchase_order, :state => 'pending')
    purchase_order.purchase_order_variants.push(create(:purchase_order_variant, :purchase_order => purchase_order, :is_received => true))
    PurchaseOrderVariant.any_instance.expects(:receive!).never
    purchase_order.receive_variants
  end
end

describe PurchaseOrder, "#admin_grid(params = {})" do
  it "should return users " do
    purchase_order1 = FactoryGirl.create(:purchase_order)
    purchase_order2 = FactoryGirl.create(:purchase_order)
    admin_grid = PurchaseOrder.admin_grid
    expect(admin_grid.size).to eq 2
    expect(admin_grid.include?(purchase_order1)).to be true
    expect(admin_grid.include?(purchase_order2)).to be true
  end
end

describe PurchaseOrder, "#receiving_admin_grid(params = {})" do
  it "should return PurchaseOrders " do
    purchase_order1 = FactoryGirl.create(:purchase_order)
    purchase_order1.state = PurchaseOrder::RECEIVED
    purchase_order1.save
    purchase_order2 = FactoryGirl.create(:purchase_order)
    admin_grid = PurchaseOrder.receiving_admin_grid
    expect(admin_grid.size).to eq 1
    expect(admin_grid.include?(purchase_order1)).to be false
    expect(admin_grid.include?(purchase_order2)).to be true
  end
end
