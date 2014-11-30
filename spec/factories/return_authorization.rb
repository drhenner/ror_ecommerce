FactoryGirl.define do
  factory :return_authorization do
    number          "34567kjhgf"
    amount          "9.99"
    restocking_fee  "3.98"
    order           { |c| c.association(:order) }
    state           "authorized"
    user            { |c| c.association(:user) }
    created_by      { |c| c.association(:user).id }

    #after(:build) {|oi| oi.send(:initialize_state_machines, :dynamic => :force)}
  end
end
