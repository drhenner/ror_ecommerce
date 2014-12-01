require 'spec_helper'

describe Supplier, "#admin_grid(params = {})" do
  it "should return Suppliers " do
    supplier1 = FactoryGirl.create(:supplier)
    supplier2 = FactoryGirl.create(:supplier)
    admin_grid = Supplier.admin_grid
    info =admin_grid.all
    expect(info.size).to eq 2
    expect(info).to eq [supplier1, supplier2]
  end
end
