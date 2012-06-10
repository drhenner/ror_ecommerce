FactoryGirl.define do
  factory :image do
    #batchable_type  'Order'
    imageable       { |c| c.association(:product) }
    caption         'Caption blah.'
    position        1
  end
end
