require 'spec_helper'

describe TransactionLedger do
  context " TransactionLedger" do
    before(:each) do
      @transaction_ledger = FactoryBot.create(:transaction_ledger)
    end

    it "should be valid with minimum attribues" do
      expect(@transaction_ledger).to be_valid
    end

  end

end
