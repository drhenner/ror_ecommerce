FactoryGirl.define do
  factory :shipment do
    order           { |c| c.association(:order) }
    address         { |c| c.association(:address) }
    #address_id      1
    shipping_method { |c| c.association(:shipping_method) }
    state           "ready_to_ship"
    shipped_at      nil
    active          true

    #after(:build) {|oi| oi.send(:initialize_state_machines, :dynamic => :force)}
  end
end
