FactoryGirl.define do
  factory :variant_supplier do
    variant_id    1#       { |c| c.association(:variant) }
    supplier      { |c| c.association(:supplier) }

    cost          98.00
    total_quantity_supplied  10
    min_quantity  10
    max_quantity  10000
    active        true
  end
end
