FactoryGirl.define do
  factory :order_item do
    price         3.00
    total         3.15
    order         { |c| c.association(:order) }
    variant       { |c| c.association(:variant) }
    tax_rate      { |c| c.association(:tax_rate) }
    shipping_rate { |c| c.association(:shipping_rate) }
    shipment      { |c| c.association(:shipment) }
    #after(:build) {|oi| oi.send(:initialize_state_machines, :dynamic => :force)}
  end
end
