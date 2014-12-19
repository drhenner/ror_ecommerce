require 'spec_helper'

describe TransactionAccount do
  context "Valid TransactionAccount" do
    TransactionAccount.all.each do |acc|
      it "should be valid" do
        expect(acc).to be_valid
      end
    end
  end#end of context
end
