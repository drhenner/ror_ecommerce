require 'spec_helper'

describe ProductType, '#admin_grid(params = {})' do
  it "should return ProductTypes " do
    product_type1 = FactoryGirl.create(:product_type)
    product_type2 = FactoryGirl.create(:product_type)
    admin_grid = ProductType.admin_grid
    info = admin_grid.all
    expect(info.size).to eq 2
    expect(info.include?(product_type1)).to be true
    expect(info.include?(product_type2)).to be true
  end
end
