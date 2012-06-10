FactoryGirl.define do
  factory :batch do
    batchable       { |c| c.association(:order) }
    name            'Blah'
  end
end
