require 'spec_helper'

describe TransactionLedger do
  context " TransactionLedger" do
    before(:each) do
      @transaction_ledger = build(:transaction_ledger)
    end
    
    it "should be valid with minimum attribues" do
      @transaction_ledger.should be_valid
    end
    
  end
  
end