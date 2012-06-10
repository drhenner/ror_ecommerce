require 'spec_helper'

describe Account do
  context "Valid Account" do
    before(:each) do
      @account = build(:account)
    end
    
    it "should be valid with minimum attributes" do
      @account.should be_valid
    end
    
    Account.all.each do |acc_type|
      it "should be valid" do 
        acc_type.should be_valid
      end
    end

  end
  
end
