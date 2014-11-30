FactoryGirl.define do
  factory :order do
    sequence(:number)
    email           'email@e.com'
    state           'in_progress'
    user            { |c| c.association(:user) }
    bill_address    { |c| c.association(:address) }
    ship_address    { |c| c.association(:address) }
    active          true
    calculated_at   Time.zone.now
    completed_at    Time.zone.now

    #after(:build) {|oi| oi.send(:initialize_state_machines, :dynamic => :force)}
  end

  factory :in_progress_order, :parent => :order do
    state           'in_progress'
  end

  factory :complete_order, :parent => :order do
    state           'complete'
  end
end
