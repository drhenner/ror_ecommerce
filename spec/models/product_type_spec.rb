require 'spec_helper'

describe ProductType, '#admin_grid(params = {})' do
  it "should return ProductTypes " do
    product_type1 = Factory(:product_type)
    product_type2 = Factory(:product_type)
    admin_grid = ProductType.admin_grid
    admin_grid.size.should == 2
    admin_grid.include?(product_type1).should be_true
    admin_grid.include?(product_type2).should be_true
  end
end
