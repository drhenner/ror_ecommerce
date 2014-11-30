require 'spec_helper'

describe PhoneType do
  describe "Seed data" do

    PhoneType.all.each do |phone_type|
      it "should be valid" do
        expect(phone_type).to be_valid
      end
    end

  end
end
