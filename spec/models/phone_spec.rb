require 'spec_helper'

describe Phone do
  context "Phone" do
    before(:each) do
      @phone = FactoryGirl.build(:phone)
    end

    it "should be valid with minimum attributes" do
      expect(@phone).to be_valid
    end

  end

end

describe Phone, "#save_default_phone(object, params)" do
  skip "test for save_default_phone(object, params)"
end
