FactoryGirl.define do
  factory :purchase_order do
    invoice_number 'John'
    tracking_number nil
    ordered_at            { Time.zone.now }
    supplier_id      1
    estimated_arrival_on  { Time.now.to_date }
    total_cost  1.01

    #after(:build) {|oi| oi.send(:initialize_state_machines, :dynamic => :force)}
  end
end
