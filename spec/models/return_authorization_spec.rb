require 'spec_helper'

describe ReturnAuthorization, 'instance methods' do
  before(:each) do
    @user                 = create(:user)
    @order                = create(:order)
    @return_authorization = create(:return_authorization, :order => @order, :user => @user)
  end

  context '.mark_items_returned' do
    it 'should mark items returned' do
      order_item                = build(:order_item, :order => @order)
      order_item.state = 'paid'
      order_item.save
      return_item               = create(:return_item, :order_item => order_item, :return_authorization => @return_authorization)
      @return_authorization.mark_items_returned
      order_item.reload.state.should == 'returned'
      return_item.reload.returned.should be_true
    end
  end
  context '.process_ledger_transactions' do
    it 'should call process rma' do
      Invoice.expects(:process_rma).once
      @return_authorization.process_ledger_transactions
    end
  end

  context '.order_number' do
    it 'should return the orders number' do
      @return_authorization.order_number.should == @order.number
    end
  end

  context '.user_name' do
    it 'should return the users name' do
      @return_authorization.user_name.should == @user.name
    end
  end

  context ".set_order_number" do
    it 'should set number ' do
      return_authorization = create(:return_authorization)
      return_authorization.number = nil
      return_authorization.set_order_number
      return_authorization.number.should_not be_nil
    end
  end

  context ".save_order_number" do
    it 'should set number and save' do
      return_authorization = create(:return_authorization)
      return_authorization.number = nil
      return_authorization.save_order_number.should be_true
      return_authorization.number.should_not == (ReturnAuthorization::NUMBER_SEED + @return_authorization.id).to_s(ReturnAuthorization::CHARACTERS_SEED)
    end
  end

  context '.set_number' do
    it 'should set number' do
      @return_authorization.set_number
      @return_authorization.number.should == (ReturnAuthorization::NUMBER_SEED + @return_authorization.id).to_s(ReturnAuthorization::CHARACTERS_SEED)
    end

    it 'should set number not to be nil' do
      return_authorization = build(:return_authorization)
      return_authorization.set_number
      return_authorization.number.should_not be_nil
    end
  end

end

describe ReturnAuthorization, "#id_from_number(num)" do
  it 'should return invoice id' do
    return_authorization     = create(:return_authorization)
    return_authorization_id  = ReturnAuthorization.id_from_number(return_authorization.number)
    return_authorization_id.should == return_authorization.id
  end
end

describe ReturnAuthorization, "#find_by_number(num)" do
  it 'should find the invoice by number' do
    return_authorization = create(:return_authorization)
    find_return_authorization = ReturnAuthorization.find_by_number(return_authorization.number)
    find_return_authorization.id.should == return_authorization.id
  end
end

describe ReturnAuthorization, '#admin_grid(params)' do
  it "should return Return Authorizations " do
    return_authorization1 = create(:return_authorization)
    return_authorization2 = create(:return_authorization)
    admin_grid = ReturnAuthorization.admin_grid
    admin_grid.size.should == 2
    admin_grid.include?(return_authorization1).should be_true
    admin_grid.include?(return_authorization2).should be_true
  end
end
