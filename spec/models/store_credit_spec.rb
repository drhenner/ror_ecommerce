require 'spec_helper'

describe StoreCredit do
  it "should be valid" do
    build(:store_credit).should be_valid
  end
end

describe StoreCredit, 'instance methods' do
  context '.remove_credit(amount_to_remove)' do
    it "should remove amount" do
      store_credit = create(:store_credit, :amount => 14.00)
      store_credit.remove_credit(10.01)
      sc = StoreCredit.find(store_credit.id)
      sc.amount.should == 3.99
    end
  end
end
