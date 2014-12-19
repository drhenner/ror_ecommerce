require 'spec_helper'

describe StoreCredit do
  it "should be valid" do
    expect(FactoryGirl.build(:store_credit)).to be_valid
  end
end

describe StoreCredit, 'instance methods' do
  context '.remove_credit(amount_to_remove)' do
    it "should remove amount" do
      store_credit = FactoryGirl.create(:store_credit, :amount => 14.00)
      store_credit.remove_credit(10.01)
      sc = StoreCredit.find(store_credit.id)
      expect(sc.amount).to eq 3.99
    end
  end
end
