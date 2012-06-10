FactoryGirl.define do
  factory :payment do
    invoice         { |c| c.association(:invoice) }
    confirmation_id  123456789
    amount          315
    message         'test message'
    action          'authorization'
    success         true
    test            true
  end
end
