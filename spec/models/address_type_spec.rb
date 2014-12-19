require 'spec_helper'

describe AddressType do
  describe "Valid Seed data" do

    AddressType.all.each do |add_type|
      it "should be valid" do
        expect(add_type).to be_valid
      end
    end

  end
end
